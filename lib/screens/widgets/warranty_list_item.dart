import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/screens/warranty_details_screen/warranty_details.dart';
import 'package:warranty_manager_cloud/screens/warranty_edit_form.dart';
import 'package:warranty_manager_cloud/services/storage.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class WarrantyListItemWidget extends StatelessWidget {
  final Product product;
  final Color color;

  const WarrantyListItemWidget(
      {super.key, required this.product, required this.color});

  Future<String> getImage() async {
    return await getProductImage(product.id!);
  }

  int calculatePendingPercentage(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final part1 = startDate.difference(now).inDays + 1;
    final part2 = startDate.difference(endDate).inDays + 1;
    final percent = ((part1 / part2) * 10).ceil();

    if (percent > 10) {
      return 10;
    } else if (percent < 0) {
      return 0;
    }
    return percent;
  }

  noImageWidget() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/noimage.jpg'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: kAppPaddingSmall,
        child: SizedBox(
          height: 125,
          child: Card(
            shadowColor: color,
            elevation: 8.0,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: product.isProductImage
                      ? FutureBuilder<String>(
                          future: getImage(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                margin: kAppPaddingSmall,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(snapshot.data!),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return noImageWidget();
                            }

                            return appLoader;
                          },
                        )
                      : noImageWidget(),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ListTile(
                          //     title: Text(product.name!),
                          //     subtitle: Text(product.company!)),
                          const SizedBox(height: 5),
                          Text(
                            product.name!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(product.company!),
                          const SizedBox(height: 10),
                          Text(
                            'expires ${Moment(product.warrantyEndDate!).fromNow()}',
                          ),
                          const SizedBox(height: 5),
                          StepProgressIndicator(
                            totalSteps: 10,
                            currentStep: calculatePendingPercentage(
                              product.purchaseDate!,
                              product.warrantyEndDate!,
                            ),
                            selectedColor: color,
                            unselectedColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PopupMenuButton(
                        iconSize: 40,
                        icon: const Icon(Icons.more_vert_outlined,
                            color: kAccentColor),
                        onSelected: (List<String> result) async {
                          if (result[0] == 'delete') {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      Text('${'delete'.tr()} ${product.name}'),
                                  content: Text('delete_confirm'.tr()),
                                  actions: <Widget>[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
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
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
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
                    ],
                  ),
                ),
              ],
            ),
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
