import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:warranty_manager_cloud/models/settings.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/locales.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    List<Locale> localeOptions = supportedLocales;

    void _onChanged(dynamic val) => debugPrint(val.toString());

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
                      name: 'lang',
                      initialValue: 'en',
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
                                value: locale.languageCode,
                                child: Text(
                                    localeLanguageMap[locale.languageCode]!),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 5),
                    FormBuilderCheckbox(
                      name: 'allow_expiry_notification',
                      initialValue: true,
                      onChanged: _onChanged,
                      title: const Text('expiry_warranty_notification').tr(),
                    ),
                    const SizedBox(height: 5),
                    FormBuilderCheckbox(
                      name: 'allow_remainder_notification',
                      initialValue: true,
                      onChanged: _onChanged,
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
                          debugPrint(formKey.currentState?.value.toString());

                          final formData = formKey.currentState?.value;
                          final settings = Settings();
                          settings.langCode = formData!['lang'] ?? 'en';
                          settings.allowExpiryNotification =
                              formData['allow_expiry_notification'];
                          settings.allowRemainderNotification =
                              formData['allow_remainder_notification'];

                          await settings.save();
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
