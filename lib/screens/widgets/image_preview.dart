import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final String image;
  final String imageName;

  const DisplayImage({super.key, required this.image, required this.imageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          imageName.isNotEmpty ? imageName : 'Image Viewer',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 11,
            child: InteractiveViewer(
              child: Image.network(
                image,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
