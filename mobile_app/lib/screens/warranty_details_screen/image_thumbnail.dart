import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/screens/widgets/image_preview.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class ImageThumbnailWidget extends StatelessWidget {
  final String image;
  final String imageName;
  const ImageThumbnailWidget(
      {super.key, required this.image, required this.imageName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        children: [
          const SizedBox(height: 25),
          Center(
            child: Text(
              imageName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            child: Image.network(
              image,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                  child,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null ? child : appLoader,
              fit: BoxFit.contain,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => DisplayImage(
                  image: image,
                  imageName: imageName,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
