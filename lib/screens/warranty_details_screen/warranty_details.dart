import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/warranty_details_screen/image_thumbnail.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';

class WarrantyDetailsScreen extends StatefulWidget {
  final Product product;
  const WarrantyDetailsScreen({super.key, required this.product});

  @override
  State<WarrantyDetailsScreen> createState() => _WarrantyDetailsScreenState();
}

class _WarrantyDetailsScreenState extends State<WarrantyDetailsScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
// get only required image
    List<String> imageList = [];
    widget.product.isProductImage ? imageList.add('productImage') : null;
    widget.product.isPurchaseCopy ? imageList.add('purchaseCopy') : null;
    widget.product.isWarrantyCopy ? imageList.add('warrantyCopy') : null;
    widget.product.isAdditionalImage ? imageList.add('additionalImage') : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Home',
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
          Navigator.pop(context);
        },
        backgroundColor: kAccentColor,
        child: const Icon(Icons.keyboard_backspace),
      ),
      body: FutureBuilder(
        future: getImages(widget.product.id!, imageList),
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
                      child: widget.product.isProductImage
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
                            widget.product.name!,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          const SizedBox(height: 7.5),
                          Text(
                            widget.product.company!,
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
                                    .format(widget.product.purchaseDate!),
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
                                widget.product.warrantyPeriod!,
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
                                    .format(widget.product.warrantyEndDate!),
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
                                widget.product.category!,
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
                                widget.product.price!.toString(),
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
                                widget.product.purchasedAt ?? '-',
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
                                widget.product.salesPerson ?? '-',
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
                                widget.product.phone ?? '-',
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
                                widget.product.email ?? '-',
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
                                widget.product.notes ?? '-',
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
                            widget.product.isProductImage
                                ? ImageThumbnailWidget(
                                    image: data!['productImage']!,
                                    imageName: 'Product Image')
                                : const SizedBox(),
                            widget.product.isPurchaseCopy
                                ? ImageThumbnailWidget(
                                    image: data!['purchaseCopy']!,
                                    imageName: 'Purchase Bill')
                                : const SizedBox(),
                            widget.product.isWarrantyCopy
                                ? ImageThumbnailWidget(
                                    image: data!['warrantyCopy']!,
                                    imageName: 'Warranty Copy')
                                : const SizedBox(),
                            widget.product.isAdditionalImage
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
