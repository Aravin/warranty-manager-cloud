import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/warranty_details_screen/image_thumbnail.dart';
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
                    padding: kAppPaddingSmall,
                    children: [
                      ListTile(
                        title: Text('Purchase date'.toUpperCase()),
                        subtitle: Text(product.purchaseDate!.toIso8601String()),
                      ),
                      ListTile(
                        title: Text('Warranty period'.toUpperCase()),
                        subtitle: Text(product.warrantyPeriod!),
                      ),
                      ListTile(
                        title: Text('Warranty End Date'.toUpperCase()),
                        subtitle:
                            Text(product.warrantyEndDate!.toIso8601String()),
                      ),
                      ListTile(
                        title: Text('Category'.toUpperCase()),
                        subtitle: Text(product.category!),
                      ),
                      ListTile(
                        title: Text('Amount'.toUpperCase()),
                        subtitle: Text(product.price!.toString()),
                      ),
                      ListTile(
                        title: Text('Purchase at'.toUpperCase()),
                        subtitle: Text(product.purchasedAt ?? '-'),
                      ),
                      ListTile(
                        title: Text('Contact Person Name'.toUpperCase()),
                        subtitle: Text(product.salesPerson ?? '-'),
                      ),
                      ListTile(
                        title: Text('Support Phone Number'.toUpperCase()),
                        subtitle: Text(product.phone ?? '-'),
                      ),
                      ListTile(
                        title: Text('Support Email'.toUpperCase()),
                        subtitle: Text(product.email ?? '-'),
                      ),
                      ListTile(
                        title: Text('Quick Note'.toUpperCase()),
                        subtitle: Text(product.notes ?? '-'),
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
