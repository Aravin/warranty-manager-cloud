import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:warranty_manager_cloud/firebase_options.dart';

class ContactApi {
  static Uri _contactUri() {
    final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
    return Uri.parse(
      'https://us-central1-$projectId.cloudfunctions.net/contact',
    );
  }

  static Future<bool> sendEmail({
    required String message,
    required String reason,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final idToken = await user.getIdToken();
    final client = http.Client();

    try {
      final response = await client.post(
        _contactUri(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'message': message,
          'reason': reason,
          'version': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
        }),
      );

      return response.statusCode == 202;
    } finally {
      client.close();
    }
  }
}
