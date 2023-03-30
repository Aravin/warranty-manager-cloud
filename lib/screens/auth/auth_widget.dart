import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/settings.dart';
import 'package:warranty_manager_cloud/screens/auth.dart';
import 'package:warranty_manager_cloud/screens/home/home.dart';
import 'package:warranty_manager_cloud/screens/onboarding/onboarding_screen.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return StreamBuilder<Settings>(
            stream: Settings().get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                context.setLocale(snapshot.data!.locale.toLocale());
                return const HomeScreen();
              }
              return appLoader;
            },
          );
        }
        return const AuthGate();
      },
    );
  }
}
