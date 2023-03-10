import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/warranty_details_screen/warranty_details.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';

class WarrantyListItemWidget extends StatelessWidget {
  final Product product;
  final Color cardColor;

  const WarrantyListItemWidget(
      {super.key, required this.product, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: kAppPaddingSmall,
        child: Container(
          padding: kAppEdgeInsets,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: cardColor ?? Color(0xFFE4E5E9),
          ),
          height: 100,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 11,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: const <Widget>[
                        Text(
                          'Purchase Date',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Valid Till',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          DateFormat.yMMMd().format(product.purchaseDate!),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(product.warrantyEndDate!),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<List<String>>(
                    onSelected: (List<String> result) async {
                      if (result[0] == 'delete') {
                        await product.delete(result[1]);
                        Fluttertoast.showToast(
                          msg: "Product Deleted Successfully!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          fontSize: 16.0,
                        );
                      } else if (result[0] == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WarrantyForm(
                              product: product,
                            ),
                          ),
                        );
                      } else if (result[0] == 'view') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WarrantyDetailsScreen(
                              product: product,
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<List<String>>>[
                      PopupMenuItem<List<String>>(
                        value: ['view', product.id.toString()],
                        child: const Text('View'),
                      ),
                      PopupMenuItem<List<String>>(
                        value: ['edit', product.id.toString()],
                        child: const Text('Edit'),
                      ),
                      PopupMenuItem<List<String>>(
                        value: ['delete', product.id.toString()],
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
