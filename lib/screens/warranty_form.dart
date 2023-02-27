import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/shared/categories.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:warranty_manager_cloud/shared/toast.dart';

class WarrantyForm extends StatefulWidget {
  const WarrantyForm({super.key});

  @override
  State<WarrantyForm> createState() => _WarrantyFormState();
}

class _WarrantyFormState extends State<WarrantyForm> {
  bool autoValidate = true;
  final _formKey = GlobalKey<FormBuilderState>();
  final _product = Product();

  void _onChanged(dynamic val) => debugPrint(val.toString());

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Edit Warranty')),
      body: Column(
        children: [
          Expanded(
            child: FormBuilder(
              key: _formKey,
              // enabled: false,
              onChanged: () {
                _formKey.currentState!.save();
                debugPrint(_formKey.currentState!.value.toString());
              },
              autoFocusOnValidationFailure: true,
              autovalidateMode: AutovalidateMode.disabled,
              initialValue: const {},
              skipDisabled: true,
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: currentStep ?? 0,
                onStepContinue: next,
                onStepTapped: (step) => goTo(step),
                onStepCancel: cancel,
                steps: [
                  Step(
                    isActive: currentStep == 0 ? true : false,
                    title: const Text('Required*'),
                    content: Column(
                      // key: UniqueKey(),
                      children: [
                        FormBuilderDateTimePicker(
                          name: "purchaseDate",
                          textInputAction: TextInputAction.next,
                          validator: FormBuilderValidators.compose(
                              [FormBuilderValidators.required()]),
                          keyboardType: TextInputType.datetime,
                          inputType: InputType.date,
                          lastDate: DateTime.now(),
                          format: DateFormat("EEE, MMMM d, yyyy"),
                          decoration: const InputDecoration(
                            labelText: "Purchase Date",
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                        FormBuilderDropdown(
                          name: "warrantyPeriod",
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.timer),
                            labelText: "Warranty Period",
                            hintText: 'Select Warranty Period',
                          ),
                          // initialValue: 'Other',

                          validator: FormBuilderValidators.compose(
                              [FormBuilderValidators.required()]),
                          items: kWarrantyPeriods
                              .map((period) => DropdownMenuItem(
                                  value: period, child: Text("$period")))
                              .toList(),
                        ),
                        FormBuilderTextField(
                          name: 'name',
                          // focusNode: productFocus,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(3),
                            FormBuilderValidators.maxLength(24)
                          ]),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.shopping_basket),
                            hintText: 'Product/Service Name ?',
                            labelText: 'Product/Service Name *',
                          ),
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(priceFocus),
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.monetization_on),
                            hintText: 'Total Bill Amount ?',
                            labelText: 'Price *',
                          ),
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(companyFocus),
                        ),
                        FormBuilderTextField(
                          name: 'company',
                          // focusNode: companyFocus,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.branding_watermark),
                            hintText: 'Company or Brand Name?',
                            labelText: 'Brand/Company',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(2),
                            FormBuilderValidators.maxLength(24)
                          ]),
                          // onEditingComplete: () => FocusScope.of(context)
                          //     .requestFocus(categoryFocus),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: currentStep == 1 ? true : false,
                    title: const Text('Optional'),
                    content: Column(
                      // key: UniqueKey(),
                      children: [
                        FormBuilderDropdown(
                          name: 'category',
                          // focusNode: categoryFocus,

                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.category),
                            hintText: 'Product Category',
                            labelText: 'Category',
                          ),
                          initialValue: 'Other',
                          items: categoryList
                              .map((category) => DropdownMenuItem(
                                  value: category, child: Text(category)))
                              .toList(),
                        ),
                        FormBuilderTextField(
                          name: 'purchasedAt',
                          // focusNode: purchasedAtFocus,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.add_location),
                            hintText: 'Where did you purchase?',
                            labelText: 'Purchased At',
                          ),
                          initialValue: '',
                          // onEditingComplete: () => FocusScope.of(context)
                          //     .requestFocus(salesPersonFocus),
                        ),
                        FormBuilderTextField(
                          name: 'salesPerson',
                          // focusNode: salesPersonFocus,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.people),
                            hintText: 'Do you remember sales person name?',
                            labelText: 'Sales Person Name',
                          ),
                          initialValue: '',
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(phoneFocus),
                        ),
                        FormBuilderTextField(
                          name: 'phone',
                          keyboardType: TextInputType.number,
                          // focusNode: phoneFocus,
                          textInputAction: TextInputAction.next,
                          initialValue: '',
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            hintText:
                                'Contact number, i.e customer care number',
                            labelText: 'Phone number',
                          ),
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(emailFocus),
                        ),
                        FormBuilderTextField(
                          name: 'email',
                          // focusNode: emailFocus,
                          textInputAction: TextInputAction.next,
                          initialValue: '',
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Customer Service E-Mail Address',
                            labelText: 'Email Address',
                          ),
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(notesFocus),
                        ),
                        FormBuilderTextField(
                          // focusNode: notesFocus,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          name: 'notes',
                          initialValue: '',
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.note_add),
                            hintText: 'Any other additional information',
                            labelText: 'Quick Note',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: currentStep == 2 ? true : false,
                    title: const Text('Attachments'),
                    content: Column(
                      // key: UniqueKey(),
                      children: [
                        FormBuilderImagePicker(
                          bottomSheetPadding: const EdgeInsets.only(bottom: 50),
                          name: 'productImage',
                          decoration: const InputDecoration(
                            labelText: 'Upload Product Image',
                          ),
                          maxImages: 1,
                          imageQuality: 75,
                          maxHeight: 720,
                          maxWidth: 720,
                        ),
                        FormBuilderImagePicker(
                          name: 'imgBill',
                          decoration: const InputDecoration(
                            labelText: 'Upload Purchased Bill/Receipt',
                          ),
                          maxImages: 1,
                          imageQuality: 75,
                          maxHeight: 720,
                          maxWidth: 720,
                        ),
                        FormBuilderImagePicker(
                          name: 'imgWarranty',
                          decoration: const InputDecoration(
                            labelText: 'Upload Warranty Copy',
                          ),
                          maxImages: 1,
                          imageQuality: 75,
                          maxHeight: 720,
                          maxWidth: 720,
                        ),
                        FormBuilderImagePicker(
                          name: 'imgAdditional',
                          decoration: const InputDecoration(
                            labelText: 'Upload Any Other Additional Image',
                          ),
                          maxImages: 1,
                          imageQuality: 75,
                          maxHeight: 720,
                          maxWidth: 720,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      dynamic formValue = _formKey.currentState!.value;
                      debugPrint(_formKey.currentState?.value.toString());
                      _product.name = formValue['name']!.toString().trim();
                      _product.price = double.parse(formValue['price']); // todo
                      _product.purchaseDate =
                          formValue['purchaseDate'] as DateTime;
                      _product.warrantyPeriod =
                          formValue['warrantyPeriod']!.toString().trim();
                      _product.purchasedAt =
                          formValue['purchasedAt']!.toString().trim();
                      _product.company =
                          formValue['company']!.toString().trim();
                      _product.salesPerson =
                          formValue['salesPerson']!.toString().trim();
                      _product.phone = formValue['phone']!.toString().trim();
                      _product.email = formValue['email']!.toString().trim();
                      _product.notes = formValue['notes']!.toString().trim();
                      // added later
                      _product.category = formValue['category'];
                      // images
                      _product.productImage = formValue['productImage']?[0];
                      _product.purchaseCopy = formValue['imgBill']?[0];
                      _product.warrantyCopy = formValue['imgWarranty']?[0];
                      _product.additionalImage = formValue['imgAdditional']?[0];

                      inspect(_product);
                      await _product.save();
                      Fluttertoast.showToast(
                        msg: "Saved Product Successfully!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        fontSize: 16.0,
                      );
                      setState(() {
                        Navigator.pop(context, true);
                      });
                    } else {
                      debugPrint(_formKey.currentState?.value.toString());
                      debugPrint('validation failed');
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                  },
                  // color: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
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
