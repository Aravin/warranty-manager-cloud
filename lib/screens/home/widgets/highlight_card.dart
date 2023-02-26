import 'package:flutter/material.dart';

import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class HighlightCard extends StatelessWidget {
  final String cardName;
  final String count;
  final Color color;
  final IconData icon;

  const HighlightCard({
    super.key,
    required this.cardName,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(7.5)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Icon(
                Icons.security,
                color: Colors.white60,
              ),
              const SizedBox(height: 5),
              Text(
                cardName.capitalized,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              const SizedBox(height: 7.5),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w800,
                  fontSize: 25.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
