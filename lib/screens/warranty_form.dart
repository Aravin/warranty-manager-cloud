import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/shared/categories.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class WarrantyForm extends StatefulWidget {
  const WarrantyForm({super.key});

  @override
  State<WarrantyForm> createState() => _WarrantyFormState();
}

class _WarrantyFormState extends State<WarrantyForm> {
  bool autoValidate = true;
  final _formKey = GlobalKey<FormBuilderState>();
  final Product _product = Product();

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Warranty')),
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
              initialValue: {},
              skipDisabled: true,
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: currentStep ?? 0,
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
                                child: const Text('Back'),
                              )
                            : const SizedBox(),
                        currentStep < 2
                            ? OutlinedButton(
                                onPressed: () => next(),
                                child: const Text('Next'),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  );
                }),
                steps: [
                  Step(
                    isActive: currentStep == 0 ? true : false,
                    title: const Text('Required*'),
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.shopping_basket),
                            hintText: 'Product/Service Name ?',
                            labelText: 'Product/Service Name *',
                          ),
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(priceFocus),
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
                          initialValue: _product.warrantyPeriod,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.timer),
                            labelText: "Warranty Period",
                            hintText: 'Select Warranty Period',
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.monetization_on),
                            hintText: 'Total Bill Amount ?',
                            labelText: 'Price *',
                          ),
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(companyFocus),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: currentStep == 1 ? true : false,
                    title: const Text('Optional'),
                    content: Column(
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
                          // onEditingComplete: () =>
                          //     FocusScope.of(context).requestFocus(phoneFocus),
                        ),
                        FormBuilderTextField(
                          name: 'phone',
                          keyboardType: TextInputType.number,
                          // focusNode: phoneFocus,
                          textInputAction: TextInputAction.next,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: kAppPaddingSmall,
                  child: OutlinedButton(
                    child: const Text('Reset'),
                    onPressed: () {
                      _formKey.currentState?.reset();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: kAppPaddingSmall,
                  child: ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () async {
                      if (_formKey.currentState!.saveAndValidate()) {
                        await EasyLoading.show(
                          status: 'loading...',
                          maskType: EasyLoadingMaskType.clear,
                        );
                        dynamic formValue = _formKey.currentState!.value;
                        debugPrint(_formKey.currentState?.value.toString());
                        _product.name = formValue['name'];
                        _product.price =
                            double.parse(formValue['price']); // todo
                        _product.purchaseDate =
                            formValue['purchaseDate'] as DateTime;
                        _product.warrantyPeriod = formValue['warrantyPeriod']!;
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

                        await _product.save();
                        Fluttertoast.showToast(
                          msg: "Saved Product Successfully!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          fontSize: 16.0,
                        );
                        await EasyLoading.dismiss();
                        setState(() {
                          Navigator.pop(context, true);
                        });
                      } else {
                        debugPrint(_formKey.currentState?.value.toString());
                        debugPrint('validation failed');
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
