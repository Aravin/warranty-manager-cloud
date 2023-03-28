import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/services/db.dart';

const collectionName = 'settings';
final userId = FirebaseAuth.instance.currentUser!.uid.toString();

class Settings {
  String locale = 'en_GB';
  bool allowExpiryNotification = true;
  bool allowRemainderNotification = true;

  toMap() {
    return {
      'langCode': locale,
      'allowExpiryNotification': allowExpiryNotification,
      'allowRemainderNotification': allowRemainderNotification
    };
  }

  save() async {
    try {
      await db.collection(collectionName).doc(userId).set(toMap());
    } catch (err) {
      debugPrint('Failed to save setting - $err');
      rethrow;
    }
  }

  Stream<Settings> get() {
    try {
      final userData = db.collection(collectionName).doc(userId).snapshots();

      return userData.map((element) {
        final settings = Settings();
        final data = element.data();

        settings.locale = data!['langCode'] ?? 'en_GB';
        settings.allowExpiryNotification =
            data['allowExpiryNotification'] ?? true;
        settings.allowRemainderNotification =
            data['allowRemainderNotification'] ?? true;

        return settings;
      });
    } catch (err) {
      debugPrint('Failed to save setting - $err');
      rethrow;
    }
  }
}
