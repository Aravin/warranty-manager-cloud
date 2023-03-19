import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/screens/widgets/image_preview.dart';

class ImageThumbnailWidget extends StatelessWidget {
  final String image;
  final String imageName;
  const ImageThumbnailWidget(
      {super.key, required this.image, required this.imageName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          imageName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          child: Image.network(
            image,
            width: 150,
            height: 150,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctxt) => DisplayImage(
                image: image,
                imageName: imageName,
              ),
            ),
          ),
        )
      ],
    );
  }
}
