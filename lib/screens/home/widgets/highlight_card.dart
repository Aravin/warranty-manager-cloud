import 'package:flutter/material.dart';

import 'package:warranty_manager_cloud/shared/constants.dart';

class HighlightCard extends StatelessWidget {
  final String cardName;
  final String count;

  const HighlightCard({
    super.key,
    required this.cardName,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: kPrimaryColor, borderRadius: BorderRadius.circular(7.5)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Expanded(
              child: Icon(
                Icons.security,
                color: Colors.white60,
              ),
            ),
            Expanded(
              child: Text(
                cardName,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ),
            Expanded(
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w800,
                  fontSize: 25.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
