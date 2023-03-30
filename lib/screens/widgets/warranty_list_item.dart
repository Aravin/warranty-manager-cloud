import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/warranty_edit_form.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:moment_dart/moment_dart.dart';
import '../warranty_details_screen/warranty_details.dart';

class WarrantyListItemWidget extends StatelessWidget {
  final Product product;
  final Color cardColor;
  final Color cardShadow;

  const WarrantyListItemWidget({
    super.key,
    required this.product,
    required this.cardColor,
    required this.cardShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: kAppPaddingSmall,
        child: Container(
          padding: kAppEdgeInsets,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            // border: Border.all(color: cardColor),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: cardColor,
                blurRadius: 1.0,
                spreadRadius: 0.5,
                offset: const Offset(0, 1), // shadow direction: bottom right
              ),
              BoxShadow(
                color: cardShadow,
                offset: const Offset(-1, 0),
              ),
              BoxShadow(
                color: cardShadow,
                offset: const Offset(1, 0),
              )
            ],
          ),
          height: 100,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          product.name!,
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.company!,
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            'purchase_date',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ).tr().text.underline.make(),
                          const Text(
                            'expires',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ).tr().text.underline.make(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(product.purchaseDate!),
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            Moment(product.warrantyEndDate!).fromNow(),
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ])
                  ],
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<List<String>>(
                    iconSize: 30,
                    icon: const Icon(Icons.more_vert, color: kAccentColor),
                    tooltip: 'tooltip.add_edit_delete_warranty'.tr(),
                    onSelected: (List<String> result) async {
                      if (result[0] == 'delete') {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('${'delete'.tr()} ${product.name}'),
                              content: Text('delete_confirm'.tr()),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('yes_delete').tr(),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await product.delete(product);
                                    Fluttertoast.showToast(
                                      msg: 'toast.delete_success'.tr(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      fontSize: 16.0,
                                    );
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('cancel').tr(),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (result[0] == 'edit') {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                WarrantyEditForm(productId: product.id!),
                          ),
                        );
                      } else if (result[0] == 'view') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WarrantyDetailsScreen(
                              productId: product.id!,
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<List<String>>>[
                      PopupMenuItem<List<String>>(
                        value: ['view', product.id.toString()],
                        child: const Text('view').tr(),
                      ),
                      PopupMenuItem<List<String>>(
                        value: ['edit', product.id.toString()],
                        child: const Text('edit').tr(),
                      ),
                      PopupMenuItem<List<String>>(
                        value: ['delete', product.id.toString()],
                        child: const Text('delete').tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WarrantyDetailsScreen(
            productId: product.id!,
          ),
        ),
      ),
    );
  }
}
