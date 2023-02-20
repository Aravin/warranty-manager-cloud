import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:warranty_manager_cloud/screens/temp.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  actionCallback(bool rebuild) {
    if (rebuild) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        textTheme: TextTheme(),
        title: Text(
          'Saved Items',
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
      body: Column(
        children: <Widget>[MyWidget(actionCallback: actionCallback)],
      ),
    );
  }
}
