import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/home/widgets/highlight_card.dart';
import 'package:warranty_manager_cloud/screens/profile.dart';
// import 'package:in_app_review/in_app_review.dart';
import 'package:warranty_manager_cloud/screens/static/about.dart';
import 'package:warranty_manager_cloud/screens/static/privacy_policy.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';

import 'package:warranty_manager_cloud/screens/warranty_list_tab_screem.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_tab.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

class Home extends StatefulWidget {
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
        title: const Text(
          'Warranty Manager',
        ),
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
                      children: const [
                        CircleAvatar(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.white,
                          radius: 36,
                          child: Text(
                            'A',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Anonymous User',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Please create an account with email address to sync your warranty!',
                          style: TextStyle(color: Colors.white),
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
              title: const Text('Saved Items'),
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
              title: const Text('Privacy Policy'),
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
              title: const Text('About'),
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
                    title: const Text('Profile'),
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
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('Yes, log me out'),
                        onPressed: () {
                          Navigator.pop(context);
                          _signOut();
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('Cancel'),
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
            debugPrint(snapshot.toString());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HighlightCard(
                      cardName: 'In Warranty',
                      count: snapshot.data!.active.length.toString(),
                      icon: Icons.security,
                    ),
                    HighlightCard(
                      cardName: 'Out of Warranty',
                      count: snapshot.data!.expired.length.toString(),
                      icon: Icons.timer_off,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                WarrantyListTabWidget(warrantyList: snapshot.data!),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const WarrantyForm(),
            ),
          );
        },
        label: const Text('Add new'),
        icon: const Icon(Icons.new_label),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
