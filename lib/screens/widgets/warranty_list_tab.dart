import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_item.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class WarrantyListTabWidget extends StatelessWidget {
  final WarrantyList warrantyList;
  const WarrantyListTabWidget({super.key, required this.warrantyList});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: TabBar(
                  indicatorColor: kAccentColor,
                  labelColor: kPrimaryColor,
                  tabs: [
                    Tab(
                      child: Text('ACTIVE (${warrantyList.active.length})'),
                    ),
                    Tab(
                      child: Text('EXPIRING (${warrantyList.expiring.length})'),
                    ),
                    Tab(
                      child: Text('EXPIRED (${warrantyList.expired.length})'),
                    ),
                  ],
                ),
                body: TabBarView(
                  children: [
                    warrantyList.active.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: warrantyList.active.length,
                            itemBuilder: ((context, index) =>
                                WarrantyListItemWidget(
                                  product: warrantyList.active[index],
                                  cardColor: Colors.green.shade200,
                                  cardShadow: Colors.green.shade100,
                                )),
                          )
                        : const Center(child: Text('No active warranty')),
                    warrantyList.expiring.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: warrantyList.expiring.length,
                            itemBuilder: ((context, index) =>
                                WarrantyListItemWidget(
                                  product: warrantyList.expiring[index],
                                  cardColor: Colors.orange.shade200,
                                  cardShadow: Colors.orange.shade100,
                                )),
                          )
                        : const Center(child: Text('No expiring warranty')),
                    warrantyList.expired.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: warrantyList.expired.length,
                            itemBuilder: ((context, index) =>
                                WarrantyListItemWidget(
                                  product: warrantyList.expired[index],
                                  cardColor: Colors.red.shade200,
                                  cardShadow: Colors.red.shade100,
                                )),
                          )
                        : const Center(child: Text('No expired warranty')),
                  ],
                ).py8(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
