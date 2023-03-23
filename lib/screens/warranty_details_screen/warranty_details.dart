import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/warranty_details_screen/image_thumbnail.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Product Details'),
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
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: Text('Loading...'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load product details'));
          }
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
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Image.network(
                                data!['productImage']!,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : Container(
                              padding: kAppPaddingSmall,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(2)),
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
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text(
                          'Purchase date'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().format(product.purchaseDate!),
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Warranty period'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.warrantyPeriod!,
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Warranty End Date'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().format(product.warrantyEndDate!),
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Category'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.category!,
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Amount'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.price!.toString(),
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Purchase at'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.purchasedAt ?? '-',
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Contact Person Name'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.salesPerson ?? '-',
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Support Phone Number'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.phone ?? '-',
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Support Email'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.email ?? '-',
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Quick Note'.toUpperCase(),
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          product.notes ?? '-',
                          style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GridView.count(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2,
                    children: [
                      product.isProductImage
                          ? ImageThumbnailWidget(
                              image: data!['productImage']!,
                              imageName: 'Product Image')
                          : const SizedBox(),
                      product.isPurchaseCopy
                          ? ImageThumbnailWidget(
                              image: data!['purchaseCopy']!,
                              imageName: 'Purchase Bill')
                          : const SizedBox(),
                      product.isWarrantyCopy
                          ? ImageThumbnailWidget(
                              image: data!['warrantyCopy']!,
                              imageName: 'Warranty Copy')
                          : const SizedBox(),
                      product.isAdditionalImage
                          ? ImageThumbnailWidget(
                              image: data!['additionalImage']!,
                              imageName: 'Additional Image')
                          : const SizedBox(),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
