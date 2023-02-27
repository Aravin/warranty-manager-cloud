import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

class WarrantyDetailsScreen extends StatelessWidget {
  final Product product;
  const WarrantyDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
// get only required image
    List<String> imageList = [];
    product.isProductImage ? imageList.add('productImage') : null;
    product.isPurchaseCopy ? imageList.add('purchaseCopy') : null;
    product.isWarrantyCopy ? imageList.add('warrantyCopy') : null;
    product.isAdditionalImage ? imageList.add('additionalImage') : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.keyboard_backspace),
      ),
      body: FutureBuilder(
        future: getImages(product.id!, imageList),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Padding(
            padding: kAppPaddingLarge,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: product.isProductImage
                          ? Container(
                              padding: kAppPaddingSmall,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(7.5)),
                              child: Image.memory(
                                data!['productImage']!,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : Container(
                              padding: kAppPaddingSmall,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(7.5)),
                              child: Image.asset('assets/noimage.jpg'),
                            ),
                    ),
                    const Expanded(flex: 1, child: SizedBox()),
                    Expanded(
                      flex: 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name!,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          const SizedBox(height: 7.5),
                          Text(
                            product.company!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
