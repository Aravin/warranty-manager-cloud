import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_with_images.dart';
import 'package:warranty_manager_cloud/screens/warranty_details_screen/image_thumbnail.dart';
import 'package:warranty_manager_cloud/screens/warranty_edit_form.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class WarrantyDetailsScreen extends StatefulWidget {
  final String productId;
  const WarrantyDetailsScreen({super.key, required this.productId});

  @override
  State<WarrantyDetailsScreen> createState() => _WarrantyDetailsScreenState();
}

class _WarrantyDetailsScreenState extends State<WarrantyDetailsScreen> {
  int _selectedIndex = 0;
  late Future<WarrantyWithImages> _warrantyWithImages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _warrantyWithImages = Product().getById(widget.productId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Product Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file),
            label: 'Attachments',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WarrantyEditForm(
                productId: widget.productId,
              ),
            ),
          );
        },
        backgroundColor: kAccentColor,
        child: const Icon(Icons.edit),
      ),
      body: FutureBuilder(
        future: _warrantyWithImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return appLoader;
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
                      child: data?.images['productImage'] != null
                          ? Container(
                              padding: kAppPaddingSmall,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Image.network(
                                data!.images['productImage']!,
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
                            data!.product.name!,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          const SizedBox(height: 7.5),
                          Text(
                            data.product.company!,
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
                _selectedIndex == 0
                    ? Expanded(
                        flex: 2,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text(
                                'Purchase date'.toUpperCase(),
                                style: const TextStyle(color: kPrimaryColor),
                              ),
                              subtitle: Text(
                                DateFormat.yMMMd()
                                    .format(data.product.purchaseDate!),
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
                                data.product.warrantyPeriod!,
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
                                DateFormat.yMMMd()
                                    .format(data.product.warrantyEndDate!),
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
                                data.product.category!,
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
                                data.product.price!.toString(),
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
                                data.product.purchasedAt ?? '-',
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
                                data.product.salesPerson ?? '-',
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
                                data.product.phone ?? '-',
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
                                data.product.email ?? '-',
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
                                data.product.notes ?? '-',
                                style: const TextStyle(
                                    color: kSecondaryTextColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 1,
                        child: GridView.count(
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                          crossAxisCount: 2,
                          children: [
                            data.product.isProductImage
                                ? ImageThumbnailWidget(
                                    image: data.images['productImage']!,
                                    imageName: 'Product Image')
                                : const SizedBox(),
                            data.product.isPurchaseCopy
                                ? ImageThumbnailWidget(
                                    image: data.images['purchaseCopy']!,
                                    imageName: 'Purchase Bill')
                                : const SizedBox(),
                            data.product.isWarrantyCopy
                                ? ImageThumbnailWidget(
                                    image: data.images['warrantyCopy']!,
                                    imageName: 'Warranty Copy')
                                : const SizedBox(),
                            data.product.isAdditionalImage
                                ? ImageThumbnailWidget(
                                    image: data.images['additionalImage']!,
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
