import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/services/db.dart';

const collectionName = 'settings';

class Settings {
  bool isAnonymous = false;
  DateTime? lastSignInTime;
  String locale = 'en_GB';
  bool allowExpiryNotification = true;
  bool allowRemainderNotification = true;
  String? email;
  String? displayName;

  Settings() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    isAnonymous = currentUser.isAnonymous;
    lastSignInTime = currentUser.metadata.lastSignInTime;
    email = currentUser.email;
    displayName = currentUser.displayName;
  }

  static String _currentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('No logged in user available');
    }

    return currentUser.uid;
  }

  Map<String, Object?> toMap() {
    return {
      'isAnonymous': isAnonymous,
      'lastSignInTime': lastSignInTime,
      'langCode': locale,
      'allowExpiryNotification': allowExpiryNotification,
      'allowRemainderNotification': allowRemainderNotification,
      'email': email,
      'displayName': displayName,
    };
  }

  Future<void> save() async {
    try {
      await db.collection(collectionName).doc(_currentUserId()).set(toMap());
    } catch (err) {
      debugPrint('Failed to save setting - $err');
      rethrow;
    }
  }

  Stream<Settings> get() {
    try {
      final userId = _currentUserId();
      final userData = db.collection(collectionName).doc(userId).snapshots();

      return userData.map((element) {
        final settings = Settings();
        final currentUser = FirebaseAuth.instance.currentUser;

        if (!element.exists) {
          return settings;
        }

        final data = element.data();
        settings.isAnonymous = currentUser?.isAnonymous ?? settings.isAnonymous;
        settings.lastSignInTime =
            currentUser?.metadata.lastSignInTime ?? settings.lastSignInTime;
        settings.locale = data!['langCode'] ?? 'en_GB';
        settings.allowExpiryNotification =
            data['allowExpiryNotification'] ?? true;
        settings.allowRemainderNotification =
            data['allowRemainderNotification'] ?? true;
        settings.email = data['email'] ?? currentUser?.email;
        settings.displayName = data['displayName'] ?? currentUser?.displayName;

        return settings;
      });
    } catch (err) {
      debugPrint('Failed to get setting - $err');
      rethrow;
    }
  }
}
