import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/screens/warranty_list_tab_screem.dart';

import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class HighlightCard extends StatelessWidget {
  final String cardName;
  final String count;
  final IconData icon;

  const HighlightCard({
    super.key,
    required this.cardName,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
              color: kPrimaryColorLight,
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: 5),
                Text(
                  cardName.capitalized,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 7.5),
                Text(
                  count,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 25.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const WarrantyListTabScreen()),
        ),
      ),
    );
  }
}
