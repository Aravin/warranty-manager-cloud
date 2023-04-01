import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/models/warranty_with_images.dart';

final storage = FirebaseStorage.instance;
final auth = FirebaseAuth.instance;
final storageRef = storage.ref();

Future<void> storeImage(String filename, File file) async {
  final imgRef = storageRef.child('${auth.currentUser!.uid}/$filename');
  final tempImgPath = '${file.absolute.parent.path}/temp.jpg';
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    tempImgPath,
    format: CompressFormat.jpeg,
    minHeight: 720,
    minWidth: 720,
  );
  await imgRef.putFile(compressedFile!);
  await File(tempImgPath).delete();
}

Future<String> getProductImage(String productId) async {
  if (productId.isEmpty) {
    return '';
  }
  final pathReference =
      storageRef.child('${auth.currentUser!.uid}/$productId/productImage');

  return await pathReference.getDownloadURL();
}

Future<WarrantyList> getProductListByProduct(List<Product> warrantyList) async {
  final productList = WarrantyList(active: [], expiring: [], expired: []);

  for (Product product in warrantyList) {
    List<String> imageList = [];
    product.isProductImage ? imageList.add('productImage') : null;
    product.isPurchaseCopy ? imageList.add('purchaseCopy') : null;
    product.isWarrantyCopy ? imageList.add('warrantyCopy') : null;
    product.isAdditionalImage ? imageList.add('additionalImage') : null;

    final images = await getImages(product.id!, imageList);

    if (product.warrantyEndDate!.isAfter(DateTime.now())) {
      productList.active.add(WarrantyWithImages(product, images));
    }

    if (product.warrantyEndDate!.isAfter(DateTime.now()) &&
        product.warrantyEndDate!
            .isBefore(DateTime.now().add(const Duration(days: 28)))) {
      productList.expiring.add(WarrantyWithImages(product, images));
    }

    if (product.warrantyEndDate!.isBefore(DateTime.now())) {
      productList.expired.add(WarrantyWithImages(product, images));
    }
  }

  return productList;
}

Future<Map<String, String>> getImages(
    String productId, List<String> imageList) async {
  final Map<String, String> images = {};

  if (productId.isEmpty) {
    return images;
  }

  for (String imageName in imageList) {
    final pathReference =
        storageRef.child('${auth.currentUser!.uid}/$productId/$imageName');

    images[imageName] = await pathReference.getDownloadURL();
  }

  return images;
}

Future<void> deleteImage(String filename) async {
  final imgRef = storageRef.child('${auth.currentUser!.uid}/$filename');
  await imgRef.delete();
}
