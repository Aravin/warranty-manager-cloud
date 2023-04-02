import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import "package:velocity_x/velocity_x.dart";

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('about').tr()),
      body: Center(
        child: Padding(
          padding: kAppEdgeInsets,
          child: Column(
            children: [
              const Text(
                'Warranty Manager',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'This is Free & open source Application. You can store the warranty information of any of your product / service. All your information are stored in your device locally.',
              ),
              const SizedBox(height: 20),
              const Text('Logo Credit:').text.bold.make(),
              const SizedBox(height: 5),
              const Text('Viknesh Karthi'),
              const Text('https://www.linkedin.com/in/vikneshkarthi/'),
              const SizedBox(height: 20),
              const Text('Icons Credit:').text.bold.make(),
              const SizedBox(height: 5),
              const Text('https://icons8.com/'),
              const Text('https://undraw.co/'),
              const SizedBox(height: 20),
              const Text('Translations Credit:').text.bold.make(),
              const SizedBox(height: 5),
              const Text('https://openai.com/blog/chatgpt'),
              const SizedBox(height: 20),
              const Text('Source Code:').text.bold.make(),
              const SizedBox(height: 5),
              const Text('https://github.com/Aravin/warranty-manager-cloud'),
              const SizedBox(height: 20),
              const Text('Bug Report:').text.bold.make(),
              const SizedBox(height: 5),
              const Text(
                  'https://github.com/Aravin/warranty-manager-cloud/issues'),
              const SizedBox(height: 20),
              const Text('New Feature Request:').text.bold.make(),
              const SizedBox(height: 5),
              const Text(
                  'https://github.com/Aravin/warranty-manager-cloud/issues')
            ],
          ),
        ),
      ),
    );
  }
}
