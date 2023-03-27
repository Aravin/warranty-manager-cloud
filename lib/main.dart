import 'dart:async';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:warranty_manager_cloud/screens/auth.dart';
import 'package:warranty_manager_cloud/screens/home/home.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';

bool shouldUseFirebaseEmulator = false;
bool shouldUseFirestoreEmulator = false;

Future<void> main() async {
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391

  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (shouldUseFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }
  if (shouldUseFirestoreEmulator) {
    db.useFirestoreEmulator('localhost', 8080);
  }

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    // Handle Crashlytics enabled status when not in Debug,
    // e.g. allow your users to opt-in to crash reporting.
  }

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 30),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.fetchAndActivate();

  FirebasePerformance performance = FirebasePerformance.instance;

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('ta', 'IN'),
          Locale('hi', 'IN')
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: const WarrantyManagerApp(),
      ),
    );
    configLoading();
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

// loader
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.chasingDots
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 250.0
    ..maskColor = const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class WarrantyManagerApp extends StatelessWidget {
  const WarrantyManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.setLocale(const Locale('hi', 'IN'));

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Warranty Manager',
      theme: ThemeData(
        // useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        textTheme: Typography.blackCupertino,
      ),
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Visibility(
                  visible: constraints.maxWidth >= 1200,
                  child: Expanded(
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.primary,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Firebase Auth Desktop',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth >= 1200
                      ? constraints.maxWidth / 2
                      : constraints.maxWidth,
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return const Home();
                      }
                      return const AuthGate();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      builder: EasyLoading.init(),
    );
  }
}
