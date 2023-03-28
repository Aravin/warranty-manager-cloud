import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/home/widgets/highlight_card.dart';
import 'package:warranty_manager_cloud/screens/profile.dart';
// import 'package:in_app_review/in_app_review.dart';
import 'package:warranty_manager_cloud/screens/static/about.dart';
import 'package:warranty_manager_cloud/screens/static/privacy_policy.dart';

import 'package:warranty_manager_cloud/screens/warranty_list_tab_screen.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_tab.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: FirebaseAuth.instance.currentUser!.isAnonymous
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'create_account_with_email'.tr(),
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        Text(
                          FirebaseAuth.instance.currentUser!.displayName
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          FirebaseAuth.instance.currentUser!.email.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
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
            // ListTile(
            //   title: Text('Bulk Actions'),
            //   leading: Icon(Icons.group_work),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (ctxt) => BulkUploadScreen()),
            //     );
            //   },
            // ),
            ListTile(
              title: const Text('terms_policy').tr(),
              leading: const Icon(Icons.description),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctxt) => PrivacyPolicyScreen(),
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
              title: const Text('logout').tr(),
              leading: const Icon(Icons.logout),
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
                          await _signOut();
                          Navigator.pop(context);
                        },
                      ),
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
            // ListTile(
            //   title: Text('Rate Us'),
            //   leading: Icon(Icons.thumbs_up_down),
            //   onTap: () async {
            //     Navigator.pop(context);
            //     final InAppReview inAppReview = InAppReview.instance;

            //     inAppReview.openStoreListing();
            //   },
            // ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Product().list(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
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
            );
          } else if (snapshot.hasError) {
            return Center(child: const Text('failed_to_load_warranty').tr());
          }
          return appLoader;
        },
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
