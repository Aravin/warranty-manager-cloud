// ref: https://noxasch.tech/blog/flutter-using-sqflite-with-riverpod/

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:warranty_manager_cloud/services/auth.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_image_picker/src/form_builder_image_picker.dart';

final COLLECTION_NAME = 'warranty';

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

  // images
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
    return {
      'name': name,
      'price': price,
      'purchaseDate': purchaseDate!.toIso8601String(),
      'warrantyPeriod': warrantyPeriod,
      'warrantyEndDate':
          _generateWarrantyEndDate(purchaseDate!, warrantyPeriod!),
      'purchasedAt': purchasedAt!.isNotEmpty ? purchasedAt!.trim() : null,
      'company': company!.isNotEmpty ? company!.trim() : null,
      'salesPerson': salesPerson!.isNotEmpty ? salesPerson!.trim() : null,
      'phone': phone!.isNotEmpty ? phone!.trim() : null,
      'email': email!.isNotEmpty ? email!.trim() : null,
      'notes': notes!.isNotEmpty ? notes!.trim() : null,
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
  }

  Future<void> save() async {
    try {
      isProductImage = (productImage != null);
      isPurchaseCopy = (purchaseCopy != null);
      isWarrantyCopy = (warrantyCopy != null);
      isAdditionalImage = (additionalImage != null);

      final addResponse = await db.collection(COLLECTION_NAME).add(toMap());
      final productId = addResponse.id;

      if (productImage != null) {
        isProductImage = true;
        await storeImage('$productId/productImage', File(productImage!.path));
      }
      if (purchaseCopy != null) {
        isPurchaseCopy = true;
        await storeImage('$productId/purchaseCopy', File(purchaseCopy!.path));
      }
      if (warrantyCopy != null) {
        isWarrantyCopy = true;
        await storeImage('$productId/warrantyCopy', File(warrantyCopy!.path));
      }
      if (additionalImage != null) {
        isAdditionalImage = true;
        await storeImage(
            '$productId/additionalImage', File(additionalImage!.path));
      }
    } catch (err) {
      debugPrint('Saved to save product - $err');
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

  Future<void> delete(String warrantyId) async {
    await db.collection(COLLECTION_NAME).doc(warrantyId).delete();
  }

  Future<void> updateProduct() async {
    // Create a Dog and add it to the dogs table.
    // final productToUpdate = Product(
    //   id: this.id,
    //   name: this.name,
    //   price: this.price,
    //   purchaseDate: this.purchaseDate,
    //   warrantyPeriod: this.warrantyPeriod,
    //   warrantyEndDate: this.warrantyEndDate,
    //   purchasedAt: this.purchasedAt,
    //   company: this.company,
    //   salesPerson: this.salesPerson,
    //   phone: this.phone,
    //   email: this.email,
    //   notes: this.notes,
    //   // productImage: this.productImage,
    //   // purchaseCopy: this.purchaseCopy,
    //   // warrantyCopy: this.warrantyCopy,
    //   // additionalImage: this.additionalImage,
    //   category: this.category,
    //   productImagePath: this.productImagePath,
    //   purchaseCopyPath: this.purchaseCopyPath,
    //   warrantyCopyPath: this.warrantyCopyPath,
    //   additionalImagePath: this.additionalImagePath,
    // );

    // // TODO: remove duplicate code
    // if (productToUpdate.warrantyPeriod.toLowerCase().indexOf('month') > 0) {
    //   var monthToAdd = int.parse(
    //       productToUpdate.warrantyPeriod.replaceAll(new RegExp(r'[^0-9]'), ''));
    //   var tempDate = productToUpdate.purchaseDate;
    //   productToUpdate.warrantyEndDate = new DateTime(
    //     tempDate.year,
    //     tempDate.month + monthToAdd,
    //     tempDate.day,
    //     tempDate.hour,
    //   );
    // } else if (productToUpdate.warrantyPeriod.toLowerCase().indexOf('year') >
    //     0) {
    //   var yearToAdd = int.parse(
    //       productToUpdate.warrantyPeriod.replaceAll(new RegExp(r'[^0-9]'), ''));
    //   var tempDate = productToUpdate.purchaseDate;
    //   productToUpdate.warrantyEndDate = new DateTime(
    //     tempDate.year + yearToAdd,
    //     tempDate.month,
    //     tempDate.day,
    //     tempDate.hour,
    //   );
    // }
  }
  Future<void> deleteProducts() async {}

  Future<int> getProductCount() async {
    return db
        .collection(COLLECTION_NAME)
        .where('userId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .snapshots()
        .length;
  }

  // for blob to path conversion
  // Future<List<Map<String, Object>>> getProductColumn(
  //     List<String> columns, int offset) async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   return await db.query('product',
  //       columns: columns, limit: 1, offset: offset, orderBy: 'id');
  // }

  updateColumn(int id, String column, String val) async {
    // Get a reference to the database.
  }

  deleteColumn(int id, String column) async {
    // Get a reference to the database.
  }

  // end of -- for blob to path conversion
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
