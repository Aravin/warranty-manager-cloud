import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/settings.dart';
import 'package:warranty_manager_cloud/screens/auth.dart';
import 'package:warranty_manager_cloud/screens/home/home.dart';
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
                // ignore: prefer_const_constructors
                return HomeScreen();
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load the page!'));
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
