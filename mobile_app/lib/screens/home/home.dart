import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/settings.dart';
import 'package:warranty_manager_cloud/screens/contact/contact_screen.dart';
import 'package:warranty_manager_cloud/screens/home/widgets/highlight_card.dart';
import 'package:warranty_manager_cloud/screens/profile.dart';
import 'package:warranty_manager_cloud/screens/settings_screen/settings_screen.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:warranty_manager_cloud/screens/static/about.dart';
import 'package:warranty_manager_cloud/screens/static/privacy_policy.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';

import 'package:warranty_manager_cloud/screens/warranty_list_tab_screen.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_tab.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum Availability { loading, available, unavailable }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppReview _inAppReview = InAppReview.instance;
  Availability _availability = Availability.loading;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> saveOnboardingSettings() async {
    final prefs = await SharedPreferences.getInstance();

    Settings settings = Settings();
    settings.locale = prefs.getString('locale')!;
    settings.allowExpiryNotification =
        prefs.getBool('allow_expiry_notification')!;
    settings.allowRemainderNotification =
        prefs.getBool('allow_remainder_notification')!;
    settings.save();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    saveOnboardingSettings();
    _initPackageInfo();
    super.initState();

    (<T>(T? o) => o!)(WidgetsBinding.instance).addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();

        setState(() {
          _availability = isAvailable && !Platform.isAndroid
              ? Availability.available
              : Availability.unavailable;

          if (_availability == Availability.available) {
            _inAppReview.requestReview();
          }
        });
      } catch (_) {
        setState(() => _availability = Availability.unavailable);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('warranty_manager').tr(),
      ),
      drawer: Drawer(
        child: Column(
          // padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: FirebaseAuth.instance.currentUser!.isAnonymous
                  ? ListView(
                      children: [
                        const CircleAvatar(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.white,
                          radius: 24,
                          child: Text(
                            'A',
                            style: TextStyle(fontSize: 36),
                          ),
                        ),
                        const SizedBox(height: 7.5),
                        Text(
                          'anonymous_user'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ).centered(),
                        const SizedBox(height: 5),
                        Text(
                          'create_account_with_email'.tr(),
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ).centered(),
                      ],
                    )
                  : ListView(
                      children: [
                        CircleAvatar(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.white,
                          radius: 36,
                          child: Text(
                            FirebaseAuth.instance.currentUser!.email
                                .toString()
                                .toUpperCase()[0],
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FirebaseAuth.instance.currentUser!.displayName != null
                            ? Text(
                                FirebaseAuth.instance.currentUser!.displayName
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ).centered()
                            : const SizedBox(),
                        const SizedBox(height: 5),
                        Text(
                          FirebaseAuth.instance.currentUser!.email.toString(),
                          style: const TextStyle(color: Colors.white),
                        ).centered(),
                      ],
                    ),
            ),
            ListTile(
              title: const Text('saved_warranty').tr(),
              leading: const Icon(Icons.security),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => const WarrantyListTabScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('settings').tr(),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                );
              },
            ),
            !(FirebaseAuth.instance.currentUser!.isAnonymous)
                ? ListTile(
                    title: const Text('profile').tr(),
                    leading: const Icon(Icons.account_box),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const ProfilePage(),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
            ListTile(
              title: const Text('contact').tr(),
              leading: const Icon(Icons.email),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const ContactScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('write_review').tr(),
              leading: const Icon(Icons.thumbs_up_down),
              onTap: () async {
                Navigator.pop(context);
                _inAppReview.openStoreListing();
              },
            ),
            _availability == Availability.available
                ? ListTile(
                    title: const Text('rate_app').tr(),
                    leading: const Icon(Icons.star),
                    onTap: () async {
                      Navigator.pop(context);
                      _inAppReview.requestReview();
                    },
                  )
                : const SizedBox(),
            const Divider(),
            ListTile(
              title: const Text('terms_policy').tr(),
              leading: const Icon(Icons.description),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('about').tr(),
              leading: const Icon(Icons.info),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const AboutScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('logout').tr(),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('logout').tr(),
                    content: const Text('are_you_sure_logout').tr(),
                    actions: <Widget>[
                      TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('yes_logout').tr(),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _signOut();
                          }),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('cancel').tr(),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(),
            ListTile(
              title: Text(
                'version ${_packageInfo.version}-${_packageInfo.buildNumber}',
              ),
              leading: const Icon(Icons.build_circle_outlined),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Product().list(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return appLoader;
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('failed_to_load_warranty').tr(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ContactScreen(),
                        ),
                      );
                    },
                    // TODO: not yet translated
                    child: const Text('Report the issue'),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder(
            future: getProductListByProduct(snapshot.data!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HighlightCard(
                            cardName: tr('in_warranty'),
                            count: snapshot.data!.active.length.toString(),
                            icon: Icons.security,
                          ),
                          HighlightCard(
                            cardName: tr('expiring_soon'),
                            count: snapshot.data!.expiring.length.toString(),
                            icon: Icons.timelapse,
                          ),
                          HighlightCard(
                            cardName: tr('expired'),
                            count: snapshot.data!.expired.length.toString(),
                            icon: Icons.dangerous,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      WarrantyListTabWidget(warrantyList: snapshot.data!),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('failed_to_load_warranty').tr(),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const ContactScreen()),
                          );
                        },
                        // TODO: not yet translated
                        child: const Text('Report the issue'),
                      ),
                    ],
                  ),
                );
              }
              return appLoader;
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WarrantyForm()),
        ),
        label: const Text('add_new').tr(),
        icon: const Icon(Icons.add_circle),
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    await FacebookAuth.instance.logOut();
  }
}
