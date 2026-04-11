import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:warranty_manager_cloud/screens/auth/auth_widget.dart';
import 'package:warranty_manager_cloud/screens/onboarding/onboarding_screen.dart';
import 'package:warranty_manager_cloud/services/db.dart';
import 'package:warranty_manager_cloud/services/remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:easy_localization/easy_localization.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

const bool shouldUseFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);
const bool shouldUseFirestoreEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);
bool isFirstLaunch = true;

Future<void> _configureNotifications() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.setAutoInitEnabled(true);

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');
  const initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await notificationsPlugin.initialize(settings: initializationSettings);

  if (Platform.isAndroid) {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification == null) {
      return;
    }

    const androidNotificationDetails = AndroidNotificationDetails(
      'default_notification_channel_id',
      'Push/Remainder Notification',
      channelDescription: 'Warranty reminders and push messages',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/ic_notification',
    );
    const notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
      id: 0,
      title: message.notification!.title,
      body: message.notification!.body,
      notificationDetails: notificationDetails,
    );
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // firebase emulators
  if (shouldUseFirebaseEmulator || shouldUseFirestoreEmulator) {
    String emulatorHost = 'localhost';
    if (!kIsWeb && Platform.isAndroid) {
      emulatorHost = '10.0.2.2';
    }
    if (shouldUseFirebaseEmulator) {
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    }
    if (shouldUseFirestoreEmulator) {
      db.useFirestoreEmulator(emulatorHost, 8080);
    }
  }

  // firebase crash analytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // firebase analytics

  // firebase performance

  // firebase remote config (failures use defaults; see services/remote_config.dart)
  await initializeRemoteConfig();

  await _configureNotifications();

  // localization
  await EasyLocalization.ensureInitialized();

  // shared preferences.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.clear(); //only for testing
  isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      fallbackLocale: defaultLocale,
      useFallbackTranslations: true,
      // useOnlyLangCode: true,
      child: const WarrantyManagerApp(),
    ),
  );
  configLoading();
}

// loader
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.chasingDots
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 250.0
    ..maskColor = const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class WarrantyManagerApp extends StatelessWidget {
  const WarrantyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // context.setLocale(const Locale('en', 'GB'));

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        secondaryHeaderColor: kSecondaryTextColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Typography.blackCupertino,
        scaffoldBackgroundColor: Colors.grey.shade200,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
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
                              'Desktop Login',
                              style: Theme.of(context).textTheme.headlineMedium,
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
                  child: isFirstLaunch
                      ? const OnBoardingPage()
                      : const AuthWidget(),
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
