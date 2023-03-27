import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_item.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:easy_localization/easy_localization.dart';

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
                  indicatorColor: kPrimaryColor,
                  labelColor: kAccentColor,
                  tabs: [
                    Tab(
                        child: Text(
                            '${'active_args'.tr()} (${warrantyList.active.length})')),
                    Tab(
                        child: Text(
                            '${'expiring_args'.tr()} (${warrantyList.expiring.length})')),
                    Tab(
                        child: Text(
                            '${'expired_args'.tr()} (${warrantyList.expired.length})')),
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
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WarrantyForm(),
                      ),
                    );
                  },
                  label: const Text('add_new').tr(),
                  icon: const Icon(Icons.new_label),
                  backgroundColor: kAccentColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
