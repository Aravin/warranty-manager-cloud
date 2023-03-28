import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/services/db.dart';

const collectionName = 'settings';
final userId = FirebaseAuth.instance.currentUser!.uid.toString();

class Settings {
  String langCode = 'en';
  bool allowExpiryNotification = true;
  bool allowRemainderNotification = true;

  toMap() {
    return {
      'langCode': langCode,
      'allowExpiryNotification': allowExpiryNotification,
      'allowRemainderNotification': allowRemainderNotification
    };
  }

  save() {
    try {
      db.collection(collectionName).doc(userId).set(toMap());
    } catch (err) {
      debugPrint('Failed to save setting - $err');
      rethrow;
    }
  }
}
