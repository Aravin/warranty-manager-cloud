import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_tab.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class WarrantyListTabScreen extends StatelessWidget {
  const WarrantyListTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('saved_warranty').tr()),
      body: Padding(
        padding: kAppPaddingSmall,
        child: Column(
          children: [
            StreamBuilder<WarrantyList>(
              stream: Product().list(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return WarrantyListTabWidget(warrantyList: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('failed_to_load_warranty_details').tr());
                }
                return appLoader;
              },
            ),
          ],
        ),
      ),
    );
  }
}
