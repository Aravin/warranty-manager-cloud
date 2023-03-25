import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

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
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    child,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null ? child : appLoader,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
