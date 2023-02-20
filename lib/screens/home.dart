import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:warranty_manager_cloud/screens/profile.dart';
// import 'package:in_app_review/in_app_review.dart';
import 'package:warranty_manager_cloud/screens/static/about.dart';
import 'package:warranty_manager_cloud/screens/static/privacy_policy.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';

import 'package:warranty_manager_cloud/screens/temp.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final product = new MyWidget();

  actionCallback(bool rebuild) {
    if (rebuild) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    actionCallback(true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Warranty Manager',
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => WarrantyForm()))
                        .then((value) => setState(() => {}))
                  }).circle(radius: 40, backgroundColor: kSecondaryColor),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 25)),
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
            ),
            ListTile(
              title: Text('Saved Items'),
              leading: Icon(Icons.security),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctxt) => MyWidget()),
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
              title: Text('Privacy Policy'),
              leading: Icon(Icons.description),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctxt) => PrivacyPolicyScreen()),
                );
              },
            ),
            ListTile(
              title: Text('About'),
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.account_box),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
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
      body: Column(
        children: [
          MyWidget(actionCallback: actionCallback),
          SizedBox(
            height: 7.0,
          ),
          MyWidget(actionCallback: actionCallback),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
