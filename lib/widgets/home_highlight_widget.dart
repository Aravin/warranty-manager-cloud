// import 'package:flutter/material.dart';
// import 'package:warranty_manager_cloud/models/product.dart';
// import 'package:warranty_manager_cloud/shared/constants.dart';

// class ProductHighlightWidget extends StatelessWidget {
//   final product = new Product();
//   final Function? actionCallback;

//   ProductHighlightWidget({super.key, this.actionCallback});

//   Future<List<Product>> _products() async {
//     return product.getProducts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: kAppEdgeInsets,
//       height: 100.0,
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                   color: kPrimaryColor,
//                   borderRadius: BorderRadius.circular(7.5)),
//               child: Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Expanded(
//                         child: Icon(
//                       Icons.security,
//                       color: Colors.white60,
//                     )),
//                     Expanded(
//                         child: Text(
//                       'In Warranty',
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15.0,
//                       ),
//                     )),
//                     Expanded(
//                       child: FutureBuilder(
//                           future: _products(),
//                           initialData: [],
//                           builder: (context, AsyncSnapshot<List> snapshot) {
//                             var inWarranty = 0;
//                             if (snapshot.hasData) {
//                               for (var i = 0; i < snapshot.data.length; i++) {
//                                 if (DateTime.parse(snapshot
//                                         .data[i].warrantyEndDate
//                                         .toString())
//                                     .isAfter(DateTime.now())) {
//                                   inWarranty++;
//                                 }
//                               }
//                             }
//                             return Text(
//                               inWarranty.toString(),
//                               style: TextStyle(
//                                 color: Colors.white60,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 25.0,
//                               ),
//                             );
//                           }),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                   color: secondaryColor,
//                   borderRadius: BorderRadius.circular(7.5)),
//               child: Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Expanded(
//                         child: Icon(
//                       Icons.timer_off,
//                       color: Colors.white60,
//                     )),
//                     Expanded(
//                         child: Text(
//                       'Out-of Warranty',
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15.0,
//                       ),
//                     )),
//                     Expanded(
//                       child: FutureBuilder(
//                           future: _products(),
//                           initialData: [],
//                           builder: (context, AsyncSnapshot<List> snapshot) {
//                             var inWarranty = 0;
//                             if (snapshot.hasData) {
//                               for (var i = 0; i < snapshot.data.length; i++) {
//                                 if (DateTime.parse(snapshot
//                                         .data[i].warrantyEndDate
//                                         .toString())
//                                     .isBefore(DateTime.now())) {
//                                   inWarranty++;
//                                 }
//                               }
//                             }
//                             return Text(
//                               inWarranty.toString(),
//                               style: TextStyle(
//                                 color: Colors.white60,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 25.0,
//                               ),
//                             );
//                           }),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
