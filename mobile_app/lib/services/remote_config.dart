import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

final remoteConfig = FirebaseRemoteConfig.instance;

/// Defaults when Remote Config has not been fetched or fetch fails.
const Map<String, dynamic> _kRemoteConfigDefaults = {
  'auth_enable_google': true,
  'auth_enable_github': false,
  'auth_enable_fb': true,
  'policy_link': 'https://tnc.aravin.net/docs/terms/',
  'SENDGRID_API_KEY': '',
  'SENDGRID_FROM_EMAIL': '',
};

Future<void> initializeRemoteConfig() async {
  await remoteConfig.setDefaults(_kRemoteConfigDefaults);
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout:
          kDebugMode ? const Duration(seconds: 10) : const Duration(seconds: 30),
      minimumFetchInterval: kDebugMode
          ? Duration.zero
          : const Duration(hours: 12),
    ),
  );
  try {
    await remoteConfig.fetchAndActivate();
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Remote Config fetch failed (using defaults/cached): $e');
    }
    await FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
  }
}
