// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/widgets.dart';
// import 'package:warranty_manager_cloud/models/product.dart';
// import 'package:warranty_manager_cloud/shared/constants.dart';

// class WarrantyListWidget extends StatelessWidget {
//   final product = Product();
//   final tempDate = DateTime.now();

//   WarrantyListWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//               child: DefaultTabController(
//             length: 3,
//             child: Scaffold(
//               appBar: TabBar(
//                 indicatorColor: kSecondaryColor,
//                 labelColor: kPrimaryColor,
//                 tabs: <Widget>[
//                   Tab(
//                     child: FutureBuilder(
//                         future: _products(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return Text('ACTIVE (' +
//                                 snapshot.data
//                                     .map((product) => product)
//                                     .where((element) => DateTime.parse(
//                                             element.warrantyEndDate.toString())
//                                         .isAfter(DateTime.now()))
//                                     .where(
//                                       (element) => DateTime.parse(element
//                                               .warrantyEndDate
//                                               .toString())
//                                           .isAfter(DateTime.now()),
//                                     )
//                                     .toList()
//                                     .length
//                                     .toString() +
//                                 ')');
//                           }
//                           return Text('ACTIVE (0)');
//                         }),
//                   ),
//                   Tab(
//                     child: FutureBuilder(
//                         future: _products(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return Text('EXPIRING (' +
//                                 snapshot.data
//                                     .map((product) => product)
//                                     .where((element) => DateTime.parse(
//                                             element.warrantyEndDate.toString())
//                                         .isAfter(DateTime.now()))
//                                     .where(
//                                       (element) => DateTime.parse(element
//                                               .warrantyEndDate
//                                               .toString())
//                                           .isBefore(
//                                         DateTime(tempDate.year,
//                                             tempDate.month + 1, tempDate.day),
//                                       ),
//                                     )
//                                     .toList()
//                                     .length
//                                     .toString() +
//                                 ')');
//                           }
//                           return Text('EXPIRING (0)');
//                         }),
//                   ),
//                   Tab(
//                     child: FutureBuilder(
//                         future: _products(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return Text('EXPIRED (' +
//                                 snapshot.data
//                                     .map((product) => product)
//                                     .where(
//                                       (element) => DateTime.parse(element
//                                               .warrantyEndDate
//                                               .toString())
//                                           .isBefore(DateTime.now()),
//                                     )
//                                     .toList()
//                                     .length
//                                     .toString() +
//                                 ')');
//                           }
//                           return Text('EXPIRED (0)');
//                         }),
//                   ),
//                 ],
//               ),
//               body: TabBarView(
//                 children: [
//                   FutureBuilder<List<Product>>(
//                     future: _products(),
//                     initialData: [],
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData && !snapshot.hasError)
//                         return Center(child: CircularProgressIndicator());

//                       if (snapshot.hasError) {
//                         return Container(
//                           padding: EdgeInsets.only(top: 20.0),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Text(
//                               'Error Occurred ' + snapshot.error.toString(),
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (snapshot.data.length == 0)
//                           return Container(
//                             padding: EdgeInsets.only(top: 20.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Text(
//                                 'No Product Saved, Click on + button to save the product details!',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                           );

//                         if (snapshot.data
//                                 .map((product) => product)
//                                 .where((element) => DateTime.parse(
//                                         element.warrantyEndDate.toString())
//                                     .isAfter(DateTime.now()))
//                                 .where(
//                                   (element) => DateTime.parse(
//                                           element.warrantyEndDate.toString())
//                                       .isAfter(DateTime.now()),
//                                 )
//                                 .toList()
//                                 .length ==
//                             0) {
//                           return Container(
//                             padding: EdgeInsets.only(top: 20.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Text(
//                                 'No Active Product!',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }

//                         return ListView(
//                           scrollDirection: Axis.vertical,
//                           shrinkWrap: true,
//                           children: snapshot.data
//                               .map((product) => ProductListItemWidget(
//                                     product: product,
//                                     actionCallback: actionCallback,
//                                     cardColor: Colors.green[100],
//                                   ))
//                               .where(
//                                 (element) => DateTime.parse(element
//                                         .product.warrantyEndDate
//                                         .toString())
//                                     .isAfter(DateTime.now()),
//                               )
//                               .toList(),
//                         );
//                       }
//                     },
//                   ),
//                   FutureBuilder<List<Product>>(
//                     future: _products(),
//                     initialData: [],
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData && !snapshot.hasError)
//                         return Center(child: CircularProgressIndicator());

//                       if (snapshot.hasError) {
//                         return Container(
//                           padding: EdgeInsets.only(top: 20.0),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Text(
//                               'Error Occurred ' + snapshot.error.toString(),
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (snapshot.data.length == 0)
//                           return Container(
//                             padding: EdgeInsets.only(top: 20.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Text(
//                                 'No Product Saved, Click on + button to save the product details!',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                           );

//                         if (snapshot.data
//                                 .map((product) => product)
//                                 .where((element) => DateTime.parse(
//                                         element.warrantyEndDate.toString())
//                                     .isAfter(DateTime.now()))
//                                 .where(
//                                   (element) => DateTime.parse(
//                                           element.warrantyEndDate.toString())
//                                       .isBefore(
//                                     DateTime(tempDate.year,
//                                         tempDate.month + 1, tempDate.day),
//                                   ),
//                                 )
//                                 .toList()
//                                 .length ==
//                             0) {
//                           return Container(
//                             padding: EdgeInsets.only(top: 20.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Text(
//                                 'No Product Expiring in 30 days!',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }

//                         return ListView(
//                           scrollDirection: Axis.vertical,
//                           shrinkWrap: true,
//                           children: snapshot.data
//                               .map((product) => ProductListItemWidget(
//                                     product: product,
//                                     actionCallback: actionCallback,
//                                     cardColor: Colors.orange[100],
//                                   ))
//                               .where((element) => DateTime.parse(element
//                                       .product.warrantyEndDate
//                                       .toString())
//                                   .isAfter(DateTime.now()))
//                               .where(
//                                 (element) => DateTime.parse(element
//                                         .product.warrantyEndDate
//                                         .toString())
//                                     .isBefore(
//                                   DateTime(tempDate.year,
//                                       tempDate.month + 1, tempDate.day),
//                                 ),
//                               )
//                               .toList(),
//                         );
//                       }
//                     },
//                   ),
//                   FutureBuilder<List<Product>>(
//                     future: _products(),
//                     initialData: [],
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData && !snapshot.hasError)
//                         return Center(child: CircularProgressIndicator());

//                       if (snapshot.hasError) {
//                         return Container(
//                           padding: EdgeInsets.only(top: 20.0),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Text(
//                               'Error Occurred ' + snapshot.error.toString(),
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (!snapshot.hasError && snapshot.data.length == 0)
//                           return Container(
//                             padding: EdgeInsets.only(top: 20.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Text(
//                                 'No Product Saved, Click on + button to save the product details!',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                           );

//                         if (!snapshot.hasError &&
//                             snapshot.data
//                                     .map((product) => product)
//                                     .where(
//                                       (element) => DateTime.parse(element
//                                               .warrantyEndDate
//                                               .toString())
//                                           .isBefore(DateTime.now()),
//                                     )
//                                     .toList()
//                                     .length ==
//                                 0) {
//                           return Container(
//                             padding: EdgeInsets.only(top: 20.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Text(
//                                 'No Products Expired!',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }
//                       }

//                       return ListView(
//                         scrollDirection: Axis.vertical,
//                         shrinkWrap: true,
//                         children: snapshot.data
//                             .map((product) => ProductListItemWidget(
//                                   product: product,
//                                   actionCallback: actionCallback,
//                                   cardColor: Colors.red[100],
//                                 ))
//                             .where(
//                               (element) => DateTime.parse(element
//                                       .product.warrantyEndDate
//                                       .toString())
//                                   .isBefore(DateTime.now()),
//                             )
//                             .toList(),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           )),
//         ],
//       ),
//     );
//   }
// }
