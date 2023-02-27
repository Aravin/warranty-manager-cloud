import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warranty_manager_cloud/models/warranty_list.dart';
import 'package:warranty_manager_cloud/screens/widgets/warranty_list_item.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

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
                indicatorColor: kSecondaryColor,
                labelColor: kPrimaryColor,
                tabs: [
                  Tab(child: Text('ACTIVE (${warrantyList.active.length})')),
                  Tab(
                      child:
                          Text('EXPIRING (${warrantyList.expiring.length})')),
                  Tab(child: Text('EXPIRED (${warrantyList.expired.length})')),
                ],
              ),
              body: TabBarView(children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: warrantyList.active.length,
                  itemBuilder: ((context, index) => WarrantyListItemWidget(
                        product: warrantyList.active[index],
                        cardColor: Colors.green.shade200,
                      )),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: warrantyList.expiring.length,
                  itemBuilder: ((context, index) => WarrantyListItemWidget(
                        product: warrantyList.expiring[index],
                        cardColor: Colors.green.shade200,
                      )),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: warrantyList.expired.length,
                  itemBuilder: ((context, index) => WarrantyListItemWidget(
                        product: warrantyList.expired[index],
                        cardColor: Colors.green.shade200,
                      )),
                ),
              ]),
            ),
          ),
        )
      ],
    ));
  }
}
