// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

import 'auth.dart';

/// Displayed as a profile image if the user doesn't have one.
const placeholderImage =
    'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';

/// Profile page shows after sign in or registerationg
class ProfilePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  late TextEditingController controller;
  final phoneController = TextEditingController();

  String? photoURL;

  bool showSaveButton = false;
  bool isLoading = false;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser!;
    controller = TextEditingController(text: user.displayName);

    controller.addListener(_onNameChanged);

    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);

    super.dispose();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _onNameChanged() {
    setState(() {
      if (controller.text == user.displayName || controller.text.isEmpty) {
        showSaveButton = false;
      } else {
        showSaveButton = true;
      }
    });
  }

  /// Map User provider data into a list of Provider Ids.
  List get userProviders => user.providerData.map((e) => e.providerId).toList();

  Future updateDisplayName() async {
    await user.updateDisplayName(controller.text);

    setState(() {
      showSaveButton = false;
    });

    // ignore: use_build_context_synchronously
    ScaffoldSnackbar.of(context).show('Name updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('profile').tr()),
      body: Padding(
        padding: kAppEdgeInsets,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                child: Text(
                  user.email!.toString().toUpperCase()[0],
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: <Widget>[
                    user.email != null && user.email != ''
                        ? ListTile(
                            title: const Text('email',
                                style: TextStyle(
                                  fontSize: 18,
                                )).tr(),
                            subtitle: Text(user.email!),
                          )
                        : const SizedBox(),
                    user.displayName != null && user.displayName != ''
                        ? ListTile(
                            title: const Text('name',
                                style: TextStyle(
                                  fontSize: 18,
                                )).tr(),
                            subtitle: Text(user.displayName!),
                          )
                        : const SizedBox(),
                    user.phoneNumber != null && user.phoneNumber != ''
                        ? ListTile(
                            title: const Text('phone',
                                style: TextStyle(
                                  fontSize: 18,
                                )).tr(),
                            subtitle: Text(user.phoneNumber!),
                          )
                        : const SizedBox(),
                    user.metadata.creationTime != null
                        ? ListTile(
                            title: const Text('created_on',
                                style: TextStyle(
                                  fontSize: 18,
                                )).tr(),
                            subtitle:
                                Text(user.metadata.creationTime.toString()),
                          )
                        : const SizedBox(),
                    user.metadata.lastSignInTime != null
                        ? ListTile(
                            title: const Text('last_sign_in',
                                style: TextStyle(
                                  fontSize: 18,
                                )).tr(),
                            subtitle:
                                Text(user.metadata.lastSignInTime.toString()),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              Text(
                'profile_page_terms'.tr(),
                style:
                    const TextStyle(fontSize: 12, color: kSecondaryTextColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Future<String?> getPhotoURLFromUser() async {
  //   String? photoURL;

  //   // Update the UI - wait for the user to enter the SMS code
  //   await showDialog<String>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('New image Url:'),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Update'),
  //           ),
  //           OutlinedButton(
  //             onPressed: () {
  //               photoURL = null;
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //         content: Container(
  //           padding: const EdgeInsets.all(20),
  //           child: TextField(
  //             onChanged: (value) {
  //               photoURL = value;
  //             },
  //             textAlign: TextAlign.center,
  //             autofocus: true,
  //           ),
  //         ),
  //       );
  //     },
  //   );

  //   return photoURL;
  // }
}
