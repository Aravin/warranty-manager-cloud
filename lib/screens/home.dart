import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:warranty_manager_cloud/screens/static/about.dart';
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
                  MaterialPageRoute(builder: (ctxt) => MyWidget()),
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
              title: Text('Rate Us'),
              leading: Icon(Icons.thumbs_up_down),
              onTap: () async {
                Navigator.pop(context);
                final InAppReview inAppReview = InAppReview.instance;

                inAppReview.openStoreListing();
              },
            ),
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
}
