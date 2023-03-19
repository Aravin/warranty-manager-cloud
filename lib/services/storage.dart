import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
