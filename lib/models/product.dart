// ref: https://noxasch.tech/blog/flutter-using-sqflite-with-riverpod/

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warranty_manager_cloud/services/auth.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_image_picker/src/form_builder_image_picker.dart';

final COLLECTION_NAME = 'warranty';

// remove (?) optional fields in future
class Product {
  int? id;
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
  XFile? productImage;
  XFile? purchaseCopy;
  XFile? warrantyCopy;
  XFile? additionalImage;

  // added later
  String? category;

  // paths
  String? productImagePath;
  String? purchaseCopyPath;
  String? warrantyCopyPath;
  String? additionalImagePath;

  // Product({
  //   this.id,
  //   this.name,
  //   this.price,
  //   this.purchaseDate,
  //   this.warrantyPeriod,
  //   this.warrantyEndDate,
  //   this.purchasedAt,
  //   this.company,
  //   this.salesPerson,
  //   this.phone,
  //   this.email,
  //   this.notes,
  //   this.productImage,
  //   this.purchaseCopy,
  //   this.warrantyCopy,
  //   this.additionalImage,
  //   this.category,
  //   this.productImagePath,
  //   this.purchaseCopyPath,
  //   this.warrantyCopyPath,
  //   this.additionalImagePath,
  // }) {
  //   if (this.warrantyEndDate == null && this.warrantyPeriod != null) {
  //     if (this.warrantyPeriod!.toLowerCase().indexOf('month') > 0) {
  //       var monthToAdd = int.parse(
  //           this.warrantyPeriod!.replaceAll(new RegExp(r'[^0-9]'), ''));
  //       var tempDate = this.purchaseDate;
  //       this.warrantyEndDate = new DateTime(
  //         tempDate!.year,
  //         tempDate.month + monthToAdd,
  //         tempDate.day,
  //         tempDate.hour,
  //       );
  //     } else if (this.warrantyPeriod!.toLowerCase().indexOf('year') > 0) {
  //       var yearToAdd = int.parse(
  //           this.warrantyPeriod!.replaceAll(new RegExp(r'[^0-9]'), ''));
  //       var tempDate = this.purchaseDate;
  //       this.warrantyEndDate = new DateTime(
  //         tempDate!.year + yearToAdd,
  //         tempDate.month,
  //         tempDate.day,
  //         tempDate.hour,
  //       );
  //     }
  //   }
  // }

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'purchaseDate': purchaseDate!.toIso8601String(),
      'warrantyPeriod': warrantyPeriod,
      'warrantyEndDate': warrantyEndDate?.toIso8601String(),
      'purchasedAt': purchasedAt,
      'company': company,
      'salesPerson': salesPerson,
      'phone': phone,
      'email': email,
      'notes': notes,
      // 'productImage': productImage,
      // 'purchaseCopy': purchaseCopy,
      // 'warrantyCopy': warrantyCopy,
      // 'additionalImage': additionalImage,
      'category': category,
      // 'productImagePath': productImagePath,
      // 'purchaseCopyPath': purchaseCopyPath,
      // 'warrantyCopyPath': warrantyCopyPath,
      // 'additionalImagePath': additionalImagePath,
      'userId': USER_ID,
    };
  }

  dynamic save() async {
    try {
      inspect(toMap());
      await db.collection('warranty').add(toMap());

      // product image
      await storeImage(File(productImage!.path));
      await storeImage(File(purchaseCopy!.path));
      await storeImage(File(warrantyCopy!.path));
      await storeImage(File(additionalImage!.path));

      // warranty image

    } catch (err) {
      debugPrint('retry called - $err');
    }

    // A method that retrieves all the dogs from the dogs table.
    Future<List<Product>> getProducts({bool retry = false}) async {
      try {
        // Get a reference to the database.

        List<String> columns = [];

        if (retry) {
          columns = [
            'id',
            'name',
            'price',
            'purchaseDate',
            'warrantyPeriod',
            'warrantyEndDate',
            'purchasedAt',
            'company',
            'salesPerson',
            'phone',
            'email',
            'notes',
            // 'productImage',
            // 'purchaseCopy',
            // 'warrantyCopy',
            // 'additionalImage',
            'category',
            'productImagePath',
            'purchaseCopyPath',
            'warrantyCopyPath',
            'additionalImagePath',
          ];
        }

        // Query the table for all The Dogs.
        final List<Map<String, dynamic>> maps = [];

        // Convert the List<Map<String, dynamic> into a List<Dog>.
        return List.generate(maps.length, (i) {
          return Product(
              // id: maps[i]['id'],
              // name: maps[i]['name'],
              // price: maps[i]['price'],
              // purchaseDate: DateTime.parse(maps[i]['purchaseDate']),
              // warrantyPeriod: maps[i]['warrantyPeriod'],
              // warrantyEndDate: DateTime.parse(maps[i]['warrantyEndDate']),
              // purchasedAt: maps[i]['purchasedAt'],
              // company: maps[i]['company'],
              // salesPerson: maps[i]['salesPerson'],
              // phone: maps[i]['phone'],
              // email: maps[i]['email'],
              // notes: maps[i]['notes'],
              // productImage: maps[i]['productImage'],
              // purchaseCopy: maps[i]['purchaseCopy'],
              // warrantyCopy: maps[i]['warrantyCopy'],
              // additionalImage: maps[i]['additionalImage'],
              // category: maps[i]['category'],
              // productImagePath: maps[i]['productImagePath'],
              // purchaseCopyPath: maps[i]['purchaseCopyPath'],
              // warrantyCopyPath: maps[i]['warrantyCopyPath'],
              // additionalImagePath: maps[i]['additionalImagePath'],
              );
        });
      } catch (err) {
        print('epix - retry called - $err');
        return await getProducts(retry: true); // getProducts(retry: true);
      }
    }

    // Define a function that inserts dogs into the database
    Future<void> insertProduct() async {
      // Create a Dog and add it to the dogs table.
      // final productToInsert = Product(
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
      //   additionalImagePath: this.additionalImagePath, additionalImage: null,
      // );
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

    Future<void> deleteProduct(int id) async {}

    Future<void> deleteProducts() async {}

    Future<int> getProductCount() async {
      return db
          .collection(COLLECTION_NAME)
          .where('userId', isEqualTo: USER_ID)
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

// this.productImagePath,
// this.purchaseCopyPath,
// this.warrantyCopyPath,
// this.additionalImagePath

  Uint8List? _fileToBlob(File file) {
    if (file != null) {
      return file.readAsBytesSync();
    }
    return null;
  }
}