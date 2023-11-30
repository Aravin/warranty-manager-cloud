import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/contact/contact_screen.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_tab.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class WarrantyListTabScreen extends StatelessWidget {
  const WarrantyListTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('saved_warranty').tr()),
      body: Padding(
        padding: kAppPaddingTiny,
        child: Column(
          children: [
            StreamBuilder(
              stream: Product().list(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FutureBuilder(
                      future: getProductListByProduct(snapshot.data!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return WarrantyListTabWidget(
                              warrantyList: snapshot.data!);
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('failed_to_load_warranty_details')
                                    .tr(),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ContactScreen(),
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
                        return appLoader;
                      });
                } else if (snapshot.hasError) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('failed_to_load_warranty_details').tr(),
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
                  ));
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
