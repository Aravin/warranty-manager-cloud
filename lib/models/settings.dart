import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/services/db.dart';

const collectionName = 'settings';
final loggedInUserId = FirebaseAuth.instance.currentUser!.uid.toString();
final currentUser = FirebaseAuth.instance.currentUser!;

class Settings {
  bool isAnonymous = currentUser.isAnonymous;
  DateTime? lastSignInTime = currentUser.metadata.lastSignInTime;
  String locale = 'en_GB';
  bool allowExpiryNotification = true;
  bool allowRemainderNotification = true;

  toMap() {
    return {
      'isAnonymous': isAnonymous,
      'lastSignInTime': lastSignInTime,
      'langCode': locale,
      'allowExpiryNotification': allowExpiryNotification,
      'allowRemainderNotification': allowRemainderNotification,
    };
  }

  save() async {
    try {
      await db.collection(collectionName).doc(loggedInUserId).set(toMap());
    } catch (err) {
      debugPrint('Failed to save setting - $err');
      rethrow;
    }
  }

  Stream<Settings> get() {
    try {
      final userData =
          db.collection(collectionName).doc(loggedInUserId).snapshots();

      return userData.map((element) {
        final settings = Settings();

        if (!element.exists) {
          return settings;
        }

        final data = element.data();
        settings.isAnonymous = currentUser.isAnonymous;
        settings.lastSignInTime = currentUser.metadata.lastSignInTime;
        settings.locale = data!['langCode'] ?? 'en_GB';
        settings.allowExpiryNotification =
            data['allowExpiryNotification'] ?? true;
        settings.allowRemainderNotification =
            data['allowRemainderNotification'] ?? true;

        return settings;
      });
    } catch (err) {
      debugPrint('Failed to get setting - $err');
      rethrow;
    }
  }
}
