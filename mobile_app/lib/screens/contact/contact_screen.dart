import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:warranty_manager_cloud/services/remote_config.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  Future<bool> sendEmail(String message, String reason) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    final sendGridApiKey = remoteConfig.getString('SENDGRID_API_KEY');
    final sendGridFromEmail =
        remoteConfig.getString('SENDGRID_FROM_EMAIL').isEmpty
            ? 'warranty-manager@exaful.com'
            : remoteConfig.getString('SENDGRID_FROM_EMAIL');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $sendGridApiKey',
    };

    final client = http.Client();

    try {
      var response = await client.post(
        Uri.https('api.sendgrid.com', '/v3/mail/send'),
        headers: headers,
        body: jsonEncode(
          {
            'personalizations': [
              {
                'to': [
                  {'email': 'aravin.it@gmail.com'}
                ],
                'subject': '$reason from Warranty Manager Cloud'
              }
            ],
            'from': {'email': sendGridFromEmail, 'name': 'Warranty Manager'},
            'content': [
              {
                'type': 'text/plain',
                'value':
                    'Hi, $message from ${FirebaseAuth.instance.currentUser?.email} - Version: $version - Build: $buildNumber'
              }
            ]
          },
        ),
      );

      if (response.statusCode != 202) {
        debugPrint('SendGrid Error: ${response.body}');
        return false;
      }

      return true;
    } catch (err) {
      debugPrint('SendGrid Exception: $err');
      return false;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('contact').tr()),
      body: Padding(
        padding: kAppEdgeInsets,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/undraw_contact.png'),
              const SizedBox(height: 25),
              FormBuilder(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    FormBuilderDropdown<String>(
                      name: 'contactReason',
                      decoration: InputDecoration(
                        labelText: 'contact_reason'.tr(),
                        hintText: 'Select contact reason',
                      ),
                      initialValue: 'feedback'.tr(),
                      items: [
                        'feedback'.tr(),
                        'complaint'.tr(),
                        'feature_request'.tr()
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      valueTransformer: (val) => val?.toString(),
                    ),
                    FormBuilderTextField(
                      name: 'message',
                      decoration: InputDecoration(
                        labelText: 'message'.tr(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxLength(500),
                      ]),
                      maxLines: 5,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        formKey.currentState?.reset();
                      },
                      // color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        'reset'.tr(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.saveAndValidate() ?? false) {
                          try {
                            await EasyLoading.show(
                              indicator: appLoader,
                            );
                            final formData = formKey.currentState?.value;
                            debugPrint(formData.toString());

                            final success = await sendEmail(
                              formData!['message'],
                              formData['contactReason'],
                            );

                            if (success) {
                              Fluttertoast.showToast(
                                msg: 'toast.contact_request_sent_success'.tr(),
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                              );
                              await EasyLoading.dismiss()
                                  .then((value) => Navigator.pop(context));
                            } else {
                              throw Exception('Send failed');
                            }
                          } catch (err) {
                            await EasyLoading.dismiss();
                            Fluttertoast.showToast(
                              msg: 'toast.contact_request_sent_failure'.tr(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                          }
                        } else {
                          debugPrint('validation failed');
                        }
                      },
                      child: Text('send'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
