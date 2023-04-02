import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_with_images.dart';
import 'package:warranty_manager_cloud/screens/home/home.dart';
import 'package:warranty_manager_cloud/shared/categories.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';

class WarrantyEditForm extends StatefulWidget {
  final String productId;

  const WarrantyEditForm({super.key, required this.productId});

  @override
  State<WarrantyEditForm> createState() => _WarrantyEditFormState();
}

class _WarrantyEditFormState extends State<WarrantyEditForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late dynamic _formInitialValues;
  late Product _product;
  late Future<WarrantyWithImages> _warrantyWithImages;

  // steps
  int currentStep = 0;
  bool complete = false;

  next() {
    currentStep + 1 != 3
        ? goTo(currentStep + 1)
        : setState(() {
            complete = true;
          });
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() {
        currentStep = step;
      });
    }
  }

  @override
  void initState() {
    _warrantyWithImages = Product().getById(widget.productId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('edit_warranty').tr()),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _warrantyWithImages,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return appLoader;
                }
                if (!snapshot.hasData) {
                  return Center(
                      child:
                          const Text('failed_to_load_warranty_details').tr());
                }
                final data = snapshot.data;
                _product = data!.product;
                _formInitialValues = {
                  'purchaseDate': _product.purchaseDate,
                  'warranty': _product.warrantyPeriod,
                  'name': _product.name,
                  'price': _product.price!.toString(),
                  'company': _product.company,
                  'purchasedAt': _product.purchasedAt,
                  'salesPerson': _product.salesPerson,
                  'phone': _product.phone,
                  'email': _product.email,
                  'notes': _product.notes,
                  'category': _product.category,
                };
                return FormBuilder(
                  key: _formKey,
                  // enabled: false,
                  onChanged: () {
                    _formKey.currentState!.save();
                    debugPrint(_formKey.currentState!.value.toString());
                  },
                  autoFocusOnValidationFailure: true,
                  autovalidateMode: AutovalidateMode.disabled,
                  initialValue: _formInitialValues,
                  skipDisabled: true,
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: currentStep,
                    onStepContinue: next,
                    onStepTapped: (step) => goTo(step),
                    onStepCancel: cancel,
                    controlsBuilder: ((context, details) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            currentStep > 0
                                ? OutlinedButton(
                                    onPressed: () => cancel(),
                                    child: const Text('back').tr(),
                                  )
                                : const SizedBox(),
                            currentStep < 2
                                ? OutlinedButton(
                                    onPressed: () => next(),
                                    child: const Text('next').tr(),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      );
                    }),
                    steps: [
                      Step(
                        isActive: currentStep == 0 ? true : false,
                        title: const Text('required').tr(),
                        content: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'name',
                              // focusNode: productFocus,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                                FormBuilderValidators.maxLength(24)
                              ]),
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.shopping_basket),
                                hintText: 'product_service_name'.tr(),
                                labelText: 'product_service_name'.tr(),
                              ),
                              // onEditingComplete: () =>
                              //     FocusScope.of(context).requestFocus(priceFocus),
                            ),
                            FormBuilderTextField(
                              name: 'company',
                              // focusNode: companyFocus,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.branding_watermark),
                                hintText: 'brand_company'.tr(),
                                labelText: 'brand_company'.tr(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(2),
                                FormBuilderValidators.maxLength(24)
                              ]),
                              // onEditingComplete: () => FocusScope.of(context)
                              //     .requestFocus(categoryFocus),
                            ),
                            FormBuilderDateTimePicker(
                              name: "purchaseDate",
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.compose(
                                  [FormBuilderValidators.required()]),
                              keyboardType: TextInputType.datetime,
                              inputType: InputType.date,
                              lastDate: DateTime.now(),
                              format: DateFormat("EEE, MMMM d, yyyy"),
                              decoration: InputDecoration(
                                labelText: 'purchase_date'.tr(),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                            ),
                            FormBuilderDropdown(
                              name: "warrantyPeriod",
                              initialValue: _product.warrantyPeriod,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.timer),
                                labelText: 'warranty_period'.tr(),
                                hintText: 'warranty_period'.tr(),
                              ),
                              validator: FormBuilderValidators.compose(
                                  [FormBuilderValidators.required()]),
                              items: kWarrantyPeriods
                                  .map((period) => DropdownMenuItem(
                                        value: period,
                                        child: Text(period),
                                      ))
                                  .toList(),
                            ),
                            FormBuilderTextField(
                              name: 'price',
                              // focusNode: priceFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.min(1),
                                FormBuilderValidators.max(9999999)
                              ]),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.monetization_on),
                                hintText: 'price'.tr(),
                                labelText: 'price'.tr(),
                              ),
                              // onEditingComplete: () =>
                              //     FocusScope.of(context).requestFocus(companyFocus),
                            ),
                            FormBuilderDropdown(
                              name: 'category',
                              // focusNode: categoryFocus,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.category),
                                hintText: 'category'.tr(),
                                labelText: 'category'.tr(),
                              ),
                              initialValue: 'Other',
                              items: categoryList
                                  .map((category) => DropdownMenuItem(
                                      value: category, child: Text(category)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Step(
                        isActive: currentStep == 1 ? true : false,
                        title: const Text('optional').tr(),
                        content: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'purchasedAt',
                              // focusNode: purchasedAtFocus,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.add_location),
                                hintText: 'where_did_you_purchase'.tr(),
                                labelText: 'purchased_at'.tr(),
                              ),
                              // onEditingComplete: () => FocusScope.of(context)
                              //     .requestFocus(salesPersonFocus),
                            ),
                            FormBuilderTextField(
                              name: 'salesPerson',
                              // focusNode: salesPersonFocus,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.people),
                                hintText:
                                    'do_you_know_contact_person_name'.tr(),
                                labelText: 'contact_person_name'.tr(),
                              ),
                              // onEditingComplete: () =>
                              //     FocusScope.of(context).requestFocus(phoneFocus),
                            ),
                            FormBuilderTextField(
                              name: 'phone',
                              keyboardType: TextInputType.number,
                              // focusNode: phoneFocus,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone),
                                hintText: 'customer_care_phone'.tr(),
                                labelText: 'support_phone'.tr(),
                              ),
                              // onEditingComplete: () =>
                              //     FocusScope.of(context).requestFocus(emailFocus),
                            ),
                            FormBuilderTextField(
                              name: 'email',
                              // focusNode: emailFocus,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                hintText: 'customer_care_email'.tr(),
                                labelText: 'support_email'.tr(),
                              ),
                              // onEditingComplete: () =>
                              //     FocusScope.of(context).requestFocus(notesFocus),
                            ),
                            FormBuilderTextField(
                              // focusNode: notesFocus,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              name: 'notes',
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.note_add),
                                hintText: 'additional_information'.tr(),
                                labelText: 'quick_note'.tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Step(
                        isActive: currentStep == 2 ? true : false,
                        title: const Text('attachments').tr(),
                        content: Column(
                          children: [
                            FormBuilderImagePicker(
                              bottomSheetPadding:
                                  const EdgeInsets.only(bottom: 50),
                              name: 'productImage',
                              decoration: InputDecoration(
                                labelText: 'upload_product_image'.tr(),
                              ),
                              maxImages: 1,
                              imageQuality: 75,
                              maxHeight: 720,
                              maxWidth: 720,
                              initialValue: [data.images['productImage']],
                            ),
                            FormBuilderImagePicker(
                              name: 'imgBill',
                              decoration: InputDecoration(
                                labelText: 'upload_purchase_bill_image'.tr(),
                              ),
                              maxImages: 1,
                              imageQuality: 75,
                              maxHeight: 720,
                              maxWidth: 720,
                              initialValue: [data.images['purchaseCopy']],
                            ),
                            FormBuilderImagePicker(
                              name: 'imgWarranty',
                              decoration: InputDecoration(
                                labelText: 'upload_warranty_image'.tr(),
                              ),
                              maxImages: 1,
                              imageQuality: 75,
                              maxHeight: 720,
                              maxWidth: 720,
                              initialValue: [data.images['warrantyCopy']],
                            ),
                            FormBuilderImagePicker(
                              name: 'imgAdditional',
                              decoration: InputDecoration(
                                labelText: 'other_image'.tr(),
                              ),
                              maxImages: 1,
                              imageQuality: 75,
                              maxHeight: 720,
                              maxWidth: 720,
                              initialValue: [data.images['additionalImage']],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('reset').tr(),
                    onPressed: () => _formKey.currentState?.reset(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('update').tr(),
                    onPressed: () async {
                      if (_formKey.currentState!.saveAndValidate()) {
                        try {
                          EasyLoading.show(
                            indicator: appLoader,
                          );
                          dynamic formValue = _formKey.currentState!.value;
                          debugPrint(_formKey.currentState?.value.toString());
                          _product.name = formValue['name']!.toString().trim();
                          _product.price =
                              double.parse(formValue['price']); // todo
                          _product.purchaseDate =
                              formValue['purchaseDate'] as DateTime;
                          _product.warrantyPeriod =
                              formValue['warrantyPeriod']!;
                          _product.purchasedAt = formValue['purchasedAt'];
                          _product.company = formValue['company'];
                          _product.salesPerson = formValue['salesPerson'];
                          _product.phone = formValue['phone'];
                          _product.email = formValue['email'];
                          _product.notes = formValue['notes'];
                          // added later
                          _product.category = formValue['category'];
                          // images
                          _product.productImage = formValue['productImage']?[0];
                          _product.purchaseCopy = formValue['imgBill']?[0];
                          _product.warrantyCopy = formValue['imgWarranty']?[0];
                          _product.additionalImage =
                              formValue['imgAdditional']?[0];

                          await _product.update();
                          Fluttertoast.showToast(
                            msg: 'toast.save_success'.tr(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            fontSize: 16.0,
                          );
                        } catch (err) {
                          Fluttertoast.showToast(
                            msg: 'toast.failed_to_save'.tr(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            fontSize: 16.0,
                          );
                        } finally {
                          await EasyLoading.dismiss();
                          setState(() {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          });
                        }
                      } else {
                        debugPrint(_formKey.currentState?.value.toString());
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
