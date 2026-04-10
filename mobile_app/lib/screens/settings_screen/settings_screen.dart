import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:warranty_manager_cloud/models/settings.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';
import 'package:warranty_manager_cloud/shared/locales.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<Settings> _loadSettings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Settings();
    }

    return Settings().get().first;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(title: const Text('settings').tr()),
      body: FutureBuilder<Settings>(
        future: _loadSettings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: appLoader);
          }

          final settings = snapshot.data!;

          return Padding(
            padding: kAppEdgeInsets,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/undraw_settings.png'),
                  FormBuilder(
                    key: formKey,
                    initialValue: {
                      'locale': settings.locale,
                      'allow_expiry_notification':
                          settings.allowExpiryNotification,
                      'allow_remainder_notification':
                          settings.allowRemainderNotification,
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          margin: kAppPaddingTiny,
                          child: FormBuilderDropdown<String>(
                            name: 'locale',
                            decoration: InputDecoration(
                              labelText: 'display_lang'.tr(),
                              hintText: 'Select Display Language',
                            ),
                            items: supportedLocales
                                .map((locale) => DropdownMenuItem(
                                      value:
                                          '${locale.languageCode}_${locale.countryCode}',
                                      child: Text(
                                        localeLanguageMap[
                                            '${locale.languageCode}_${locale.countryCode}']!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 5),
                        FormBuilderCheckbox(
                          name: 'allow_expiry_notification',
                          title:
                              const Text('expiry_warranty_notification').tr(),
                        ),
                        const SizedBox(height: 5),
                        FormBuilderCheckbox(
                          name: 'allow_remainder_notification',
                          title: const Text('remainder_to_story_notification')
                              .tr(),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            formKey.currentState?.reset();
                          },
                          child: Text(
                            'reset'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.saveAndValidate() ??
                                false) {
                              try {
                                await EasyLoading.show(
                                  indicator: appLoader,
                                );
                                final formData = formKey.currentState?.value;
                                final nextSettings = Settings();
                                nextSettings.locale =
                                    formData!['locale'] ?? 'en_GB';
                                nextSettings.allowExpiryNotification =
                                    formData['allow_expiry_notification'] ??
                                        true;
                                nextSettings.allowRemainderNotification =
                                    formData['allow_remainder_notification'] ??
                                        true;

                                await nextSettings.save();
                                if (context.mounted) {
                                  await context.setLocale(
                                    nextSettings.locale.toLocale(),
                                  );
                                }
                                Fluttertoast.showToast(
                                  msg: 'toast.settings_save_success'.tr(),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                );
                              } catch (err) {
                                Fluttertoast.showToast(
                                  msg: 'toast.settings_save_failure'.tr(),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                );
                              } finally {
                                await EasyLoading.dismiss();
                              }

                              if (!context.mounted) {
                                return;
                              }
                              Navigator.pop(context);
                            } else {
                              debugPrint('validation failed');
                            }
                          },
                          child: Text('save'.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
