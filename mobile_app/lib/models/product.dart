import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/warranty_with_images.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:cross_file/cross_file.dart';

const collectionName = 'warranty';

// remove (?) optional fields in future
class Product {
  String? id;
  String? name;
  double? price; // todo
  DateTime? purchaseDate;
  String? warrantyPeriod;
  String? purchasedAt;
  String? company;
  String? salesPerson;
  String? phone;
  String? email;
  String? notes;

  // calculated field
  DateTime? warrantyEndDate;

  // images XFile or string
  XFile? productImage;
  XFile? purchaseCopy;
  XFile? warrantyCopy;
  XFile? additionalImage;

  // bool
  bool isProductImage = false;
  bool isPurchaseCopy = false;
  bool isWarrantyCopy = false;
  bool isAdditionalImage = false;

  // added later
  String? category;

  static String _currentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('No logged in user available');
    }

    return currentUser.uid;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getOwnedDocument(
      String productId) async {
    final doc = await db.collection(collectionName).doc(productId).get();
    final data = doc.data();

    if (!doc.exists || data == null) {
      throw StateError('Warranty not found');
    }

    if (data['userId'] != _currentUserId()) {
      throw StateError('Unauthorized warranty access');
    }

    return doc;
  }

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    try {
      return {
        'name': name?.trim(),
        'price': price,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'warrantyPeriod': warrantyPeriod,
        'warrantyEndDate':
            _generateWarrantyEndDate(purchaseDate!, warrantyPeriod!),
        'purchasedAt': purchasedAt?.trim(),
        'company': company?.trim(),
        'salesPerson': salesPerson?.trim(),
        'phone': phone?.trim(),
        'email': email?.trim(),
        'notes': notes?.trim(),
        // 'productImage': productImage,
        // 'purchaseCopy': purchaseCopy,
        // 'warrantyCopy': warrantyCopy,
        // 'additionalImage': additionalImage,
        'isProductImage': isProductImage,
        'isPurchaseCopy': isPurchaseCopy,
        'isWarrantyCopy': isWarrantyCopy,
        'isAdditionalImage': isAdditionalImage,
        'category': category,
        'userId': _currentUserId(),
      };
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Product firebaseToMap(Product product, Map<String, dynamic> data) {
    product.name = data['name'];
    product.price = data['price'];
    product.purchaseDate = DateTime.parse(data['purchaseDate']);
    product.warrantyPeriod = data['warrantyPeriod'];
    product.purchasedAt = data['purchasedAt'];
    product.company = data['company'];
    product.salesPerson = data['salesPerson'];
    product.phone = data['phone'];
    product.email = data['email'];
    product.notes = data['notes'];
    // added later
    product.category = data['category'];
    // calculated field
    product.warrantyEndDate = DateTime.parse(data['warrantyEndDate']);
    // paths
    product.isProductImage = data['isProductImage'] ?? false;
    product.isPurchaseCopy = data['isPurchaseCopy'] ?? false;
    product.isWarrantyCopy = data['isWarrantyCopy'] ?? false;
    product.isAdditionalImage = data['isAdditionalImage'] ?? false;

    return product;
  }

  Future<String> save() async {
    try {
      isProductImage = (productImage != null);
      isPurchaseCopy = (purchaseCopy != null);
      isWarrantyCopy = (warrantyCopy != null);
      isAdditionalImage = (additionalImage != null);

      final productDoc = db.collection(collectionName).doc(); //.add(toMap());
      final productId = productDoc.id;

      if (isProductImage) {
        await storeImage('$productId/productImage', File(productImage!.path));
      }
      if (isPurchaseCopy) {
        await storeImage('$productId/purchaseCopy', File(purchaseCopy!.path));
      }
      if (isWarrantyCopy) {
        await storeImage('$productId/warrantyCopy', File(warrantyCopy!.path));
      }
      if (isAdditionalImage) {
        await storeImage(
            '$productId/additionalImage', File(additionalImage!.path));
      }

      productDoc.set(toMap());

      return productId;
    } catch (err) {
      debugPrint('Failed to save product - $err');
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      isProductImage = productImage != null;
      isPurchaseCopy = purchaseCopy != null;
      isWarrantyCopy = warrantyCopy != null;
      isAdditionalImage = additionalImage != null;

      final productId = id;
      if (productId == null) {
        throw StateError('Product id is required for update');
      }

      final existingProduct = (await getById(productId)).product;

      if (isProductImage && !productImage!.path.contains('https')) {
        await storeImage('$productId/productImage', File(productImage!.path));
      } else if (!isProductImage && existingProduct.isProductImage) {
        await deleteImageIfExists('$productId/productImage');
      }
      if (isPurchaseCopy && !purchaseCopy!.path.contains('https')) {
        await storeImage('$productId/purchaseCopy', File(purchaseCopy!.path));
      } else if (!isPurchaseCopy && existingProduct.isPurchaseCopy) {
        await deleteImageIfExists('$productId/purchaseCopy');
      }
      if (isWarrantyCopy && !warrantyCopy!.path.contains('https')) {
        await storeImage('$productId/warrantyCopy', File(warrantyCopy!.path));
      } else if (!isWarrantyCopy && existingProduct.isWarrantyCopy) {
        await deleteImageIfExists('$productId/warrantyCopy');
      }
      if (isAdditionalImage && !additionalImage!.path.contains('https')) {
        await storeImage(
            '$productId/additionalImage', File(additionalImage!.path));
      } else if (!isAdditionalImage && existingProduct.isAdditionalImage) {
        await deleteImageIfExists('$productId/additionalImage');
      }

      await _getOwnedDocument(productId);
      await db.collection(collectionName).doc(productId).update(toMap());
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Future<WarrantyWithImages> getById(String productId) async {
    try {
      Product product = Product();
      product.id = productId;

      final doc = await _getOwnedDocument(productId);
      product = firebaseToMap(product, doc.data()!);

      List<String> imageList = [];
      product.isProductImage ? imageList.add('productImage') : null;
      product.isPurchaseCopy ? imageList.add('purchaseCopy') : null;
      product.isWarrantyCopy ? imageList.add('warrantyCopy') : null;
      product.isAdditionalImage ? imageList.add('additionalImage') : null;

      final images = await getImages(productId, imageList);

      return WarrantyWithImages(product, images);
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Stream<List<Product>> list() {
    try {
      final dbStream = db
          .collection(collectionName)
          .where('userId', isEqualTo: _currentUserId())
          .orderBy('warrantyEndDate')
          .snapshots();

      final productStream = dbStream.map((event) {
        final List<Product> productList = [];

        // if (!event.metadata.hasPendingWrites && !event.metadata.isFromCache) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in event.docs) {
          Product product = Product();
          final data = doc.data();

          product = firebaseToMap(product, data);
          product.id = doc.id;

          // ignore recently saved doc from list
          // if (doc.id == event.docChanges.first.doc.id && !firstTimeDoc) {
          //   firstTimeDoc = true;
          //   continue;
          // }

          productList.add(product);
        }

        return productList;
      });

      return productStream;
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Future<void> delete(Product product) async {
    try {
      final productId = product.id;
      if (productId == null) {
        throw StateError('Product id is required for delete');
      }

      await _getOwnedDocument(productId);

      if (product.isProductImage) {
        await deleteImage('$productId/productImage');
      }
      if (product.isPurchaseCopy) {
        await deleteImage('$productId/purchaseCopy');
      }
      if (product.isWarrantyCopy) {
        await deleteImage('$productId/warrantyCopy');
      }
      if (product.isAdditionalImage) {
        await deleteImage('$productId/additionalImage');
      }

      await db.collection(collectionName).doc(productId).delete();
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Future<int> getProductCount() async {
    return db
        .collection(collectionName)
        .where('userId', isEqualTo: _currentUserId())
        .snapshots()
        .length;
  }
}

String _generateWarrantyEndDate(DateTime purchaseDate, String warrantyPeriod) {
  if (warrantyPeriod.toLowerCase().indexOf('month') > 0) {
    var monthToAdd =
        int.parse(warrantyPeriod.replaceAll(RegExp(r'[^0-9]'), ''));
    var tempDate = purchaseDate;
    return DateTime(
      tempDate.year,
      tempDate.month + monthToAdd,
      tempDate.day,
      tempDate.hour,
    ).toIso8601String();
  } else {
    var yearToAdd = int.parse(warrantyPeriod.replaceAll(RegExp(r'[^0-9]'), ''));
    var tempDate = purchaseDate;
    return DateTime(
      tempDate.year + yearToAdd,
      tempDate.month,
      tempDate.day,
      tempDate.hour,
    ).toIso8601String();
  }
}
