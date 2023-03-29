import 'package:easy_localization/easy_localization.dart';
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

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    List<Locale> localeOptions = supportedLocales;

    return Scaffold(
      appBar: AppBar(title: const Text('settings').tr()),
      body: Padding(
        padding: kAppEdgeInsets,
        child: SingleChildScrollView(
          child: Column(
            children: [
              FormBuilder(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    FormBuilderDropdown<String>(
                      name: 'locale',
                      initialValue: context.locale.toString(),
                      decoration: InputDecoration(
                        labelText: 'display_lang'.tr(),
                        suffix: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            formKey.currentState!.reset();
                          },
                        ),
                        hintText: 'Select Display Language',
                      ),
                      items: localeOptions
                          .map((locale) => DropdownMenuItem(
                                value:
                                    '${locale.languageCode}_${locale.countryCode}',
                                child: Text(localeLanguageMap[
                                    '${locale.languageCode}_${locale.countryCode}']!),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 5),
                    FormBuilderCheckbox(
                      name: 'allow_expiry_notification',
                      initialValue: true,
                      title: const Text('expiry_warranty_notification').tr(),
                    ),
                    const SizedBox(height: 5),
                    FormBuilderCheckbox(
                      name: 'allow_remainder_notification',
                      initialValue: true,
                      title: const Text('remainder_to_story_notification').tr(),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.saveAndValidate() ?? false) {
                          try {
                            await EasyLoading.show(
                              indicator: appLoader,
                            );
                            final formData = formKey.currentState?.value;
                            final settings = Settings();
                            settings.locale = formData!['locale'] ?? 'en_GB';
                            settings.allowExpiryNotification =
                                formData['allow_expiry_notification'];
                            settings.allowRemainderNotification =
                                formData['allow_remainder_notification'];

                            await settings.save();
                            Fluttertoast.showToast(
                              msg: 'toast.settings_save_success'.tr(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                          } catch (err) {
                            debugPrint(formKey.currentState?.value.toString());
                            Fluttertoast.showToast(
                              msg: 'toast.settings_save_failure'.tr(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                          } finally {
                            await EasyLoading.dismiss()
                                .then((value) => Navigator.pop(context));
                          }
                        } else {
                          debugPrint(formKey.currentState?.value.toString());
                          debugPrint('validation failed');
                        }
                      },
                      child: Text('save'.tr()),
                    ),
                  ),
                  const SizedBox(width: 20),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
