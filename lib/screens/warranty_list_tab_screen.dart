import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_tab.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

class WarrantyListTabScreen extends StatelessWidget {
  const WarrantyListTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warranty List')),
      body: Padding(
        padding: kAppPaddingSmall,
        child: Column(
          children: [
            StreamBuilder<WarrantyList>(
              stream: Product().list(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  // return const Center(child: Text('Fetching data...'));

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Failed to display saved warranty'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No Saved Products'));
                  }

                  return WarrantyListTabWidget(warrantyList: snapshot.data!);
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
