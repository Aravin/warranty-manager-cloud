import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/storage.dart';

class WarrantyRepository {
  static const String collectionName = 'warranty';

  String _currentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('No logged in user available');
    }
    return currentUser.uid;
  }

  /// Returns a stream of active products directly from Firestore
  Stream<List<Product>> streamAllProducts() {
    try {
      return db
          .collection(collectionName)
          .where('userId', isEqualTo: _currentUserId())
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Product> products = [];
        for (var doc in querySnapshot.docs) {
          final product = Product()
              .firebaseToMap(Product(), doc.data() as Map<String, dynamic>);
          product.id = doc.id;
          products.add(product);
        }
        return products;
      });
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  /// Combines the Firestore product stream with Storage image resolution
  /// outputting a fully assembled, sorted WarrantyList stream.
  Stream<WarrantyList> getWarrantyListStream() {
    return streamAllProducts().asyncMap((products) async {
      return await getProductListByProduct(products);
    });
  }
}
