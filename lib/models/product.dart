// ref: https://noxasch.tech/blog/flutter-using-sqflite-with-riverpod/

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:cross_file/cross_file.dart';

const COLLECTION_NAME = 'warranty';

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
  dynamic productImage;
  dynamic purchaseCopy;
  dynamic warrantyCopy;
  dynamic additionalImage;

  // bool
  bool isProductImage = false;
  bool isPurchaseCopy = false;
  bool isWarrantyCopy = false;
  bool isAdditionalImage = false;

  // added later
  String? category;

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
        'userId': FirebaseAuth.instance.currentUser!.uid.toString(),
      };
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Future<void> save() async {
    try {
      isProductImage = (productImage != null);
      isPurchaseCopy = (purchaseCopy != null);
      isWarrantyCopy = (warrantyCopy != null);
      isAdditionalImage = (additionalImage != null);

      final addResponse = await db.collection(COLLECTION_NAME).add(toMap());
      final productId = addResponse.id;

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
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      isProductImage = productImage != null;
      isPurchaseCopy = purchaseCopy != null;
      isWarrantyCopy = warrantyCopy != null;
      isAdditionalImage = additionalImage != null;

      await db.collection(COLLECTION_NAME).doc(id).update(toMap());
      final productId = id;

      if (isProductImage && productImage is XFile) {
        await storeImage('$productId/productImage', File(productImage!.path));
      }
      if (isPurchaseCopy && purchaseCopy is XFile) {
        await storeImage('$productId/purchaseCopy', File(purchaseCopy!.path));
      }
      if (isWarrantyCopy && warrantyCopy is XFile) {
        await storeImage('$productId/warrantyCopy', File(warrantyCopy!.path));
      }
      if (isAdditionalImage && additionalImage is XFile) {
        await storeImage(
            '$productId/additionalImage', File(additionalImage!.path));
      }
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Stream<WarrantyList> list() {
    try {
      final dbStream = db
          .collection(COLLECTION_NAME)
          .where('userId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
          .snapshots();

      final productStream = dbStream.map((event) {
        final WarrantyList productObject =
            WarrantyList(active: [], expiring: [], expired: []);
        final List<Product> productList = [];

        event.docs.forEach((doc) {
          final product = Product();
          final data = doc.data();

          product.id = doc.id;
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

          if (product.warrantyEndDate!.isAfter(DateTime.now())) {
            productObject.active.add(product);
          }

          if (product.warrantyEndDate!
              .isBefore(DateTime.now().add(const Duration(days: 28)))) {
            productObject.expiring.add(product);
          }

          if (product.warrantyEndDate!.isBefore(DateTime.now())) {
            productObject.expired.add(product);
          }
          // productList.add(product);
        });

        return productObject;
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

      await db.collection(COLLECTION_NAME).doc(product.id).delete();
    } catch (err) {
      debugPrint('Saved to save product - $err');
      rethrow;
    }
  }

  Future<int> getProductCount() async {
    return db
        .collection(COLLECTION_NAME)
        .where('userId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .snapshots()
        .length;
  }
}

Uint8List? _fileToBlob(File file) {
  if (file != null) {
    return file.readAsBytesSync();
  }
  return null;
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
