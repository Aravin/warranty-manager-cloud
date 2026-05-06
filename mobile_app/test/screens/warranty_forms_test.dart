import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warranty_manager_cloud/models/product.dart';
import 'package:warranty_manager_cloud/models/warranty_with_images.dart';
import 'package:warranty_manager_cloud/screens/warranty_edit_form.dart';
import 'package:warranty_manager_cloud/screens/warranty_form.dart';
import 'package:warranty_manager_cloud/shared/locales.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const flutterToastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(flutterToastChannel, (_) async => true);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(flutterToastChannel, null);
  });

  setUp(() {
    EasyLoading.dismiss();
  });

  group('WarrantyForm', () {
    testWidgets('does not submit when required fields are missing', (
      tester,
    ) async {
      Product? submittedProduct;

      await _pumpTestApp(
        tester,
        WarrantyForm(
          onSave: (product) async {
            submittedProduct = product;
            return 'created-id';
          },
          onSaveSuccess: (_, __) {},
        ),
      );

      await tester.tap(_actionButtonFinder());
      await tester.pumpAndSettle();

      expect(submittedProduct, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('submits prefilled values without optional images', (
      tester,
    ) async {
      Product? submittedProduct;

      await _pumpTestApp(
        tester,
        WarrantyForm(
          onSave: (product) async {
            submittedProduct = product;
            return 'created-id';
          },
          onSaveSuccess: (_, __) {},
        ),
      );

      _fillWarrantyForm(
        tester,
        name: 'Electric coconut scraper',
        company: 'Sowbaghya',
        purchaseDate: DateTime(2026, 5, 3),
        warrantyPeriod: '2 Year',
        category: 'Other',
        price: '2500',
        purchasedAt: 'Kodai Kondattam Maduravoyal',
      );
      await tester.pump();

      await tester.tap(_actionButtonFinder());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(submittedProduct, isNotNull);
      expect(submittedProduct!.name, 'Electric coconut scraper');
      expect(submittedProduct!.company, 'Sowbaghya');
      expect(submittedProduct!.purchaseDate, DateTime(2026, 5, 3));
      expect(submittedProduct!.warrantyPeriod, '2 Year');
      expect(submittedProduct!.category, 'Other');
      expect(submittedProduct!.price, 2500);
      expect(submittedProduct!.purchasedAt, 'Kodai Kondattam Maduravoyal');
      expect(submittedProduct!.productImage, isNull);
      expect(submittedProduct!.purchaseCopy, isNull);
      expect(submittedProduct!.warrantyCopy, isNull);
      expect(submittedProduct!.additionalImage, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('WarrantyForm initialData', () {
    testWidgets('pre-populates all text fields from initialData', (
      tester,
    ) async {
      final initialData = {
        'name': 'Samsung TV',
        'company': 'Samsung',
        'purchaseDate': DateTime(2025, 1, 15),
        'warrantyPeriod': '2 Year',
        'category': 'Electronics and Appliances',
        'price': '45000',
        'purchasedAt': 'Croma Store',
        'salesPerson': 'John Doe',
        'phone': '9876543210',
        'email': 'support@samsung.com',
        'notes': 'Keep the receipt safe',
      };

      await _pumpTestApp(tester, WarrantyForm(initialData: initialData));

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['name']?.value, 'Samsung TV');
      expect(formState.fields['company']?.value, 'Samsung');
      expect(formState.fields['purchaseDate']?.value, DateTime(2025, 1, 15));
      expect(formState.fields['warrantyPeriod']?.value, '2 Year');
      expect(formState.fields['category']?.value, 'Electronics and Appliances');
      expect(formState.fields['price']?.value, '45000');
      expect(formState.fields['purchasedAt']?.value, 'Croma Store');
      expect(formState.fields['salesPerson']?.value, 'John Doe');
      expect(formState.fields['phone']?.value, '9876543210');
      expect(formState.fields['email']?.value, 'support@samsung.com');
      expect(formState.fields['notes']?.value, 'Keep the receipt safe');
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows empty text fields and Other category when initialData is null', (
      tester,
    ) async {
      await _pumpTestApp(tester, const WarrantyForm());

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['name']?.value, isNull);
      expect(formState.fields['company']?.value, isNull);
      expect(formState.fields['purchaseDate']?.value, isNull);
      // warrantyPeriod falls back to Product().warrantyPeriod which is null
      expect(formState.fields['warrantyPeriod']?.value, isNull);
      // category falls back to 'Other'
      expect(formState.fields['category']?.value, 'Other');
      expect(formState.fields['price']?.value, isNull);
      expect(formState.fields['purchasedAt']?.value, isNull);
      expect(formState.fields['salesPerson']?.value, isNull);
      expect(formState.fields['phone']?.value, isNull);
      expect(formState.fields['email']?.value, isNull);
      expect(formState.fields['notes']?.value, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('defaults category to Other when initialData has no category key', (
      tester,
    ) async {
      // Provide initialData without a category entry
      await _pumpTestApp(
        tester,
        WarrantyForm(initialData: {'name': 'Mixer'}),
      );

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['category']?.value, 'Other');
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses initialData category over the Other default', (
      tester,
    ) async {
      await _pumpTestApp(
        tester,
        WarrantyForm(initialData: {'category': 'Electronics and Appliances'}),
      );

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['category']?.value, 'Electronics and Appliances');
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses initialData warrantyPeriod over Product default', (
      tester,
    ) async {
      await _pumpTestApp(
        tester,
        WarrantyForm(initialData: {'warrantyPeriod': '5 Year'}),
      );

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['warrantyPeriod']?.value, '5 Year');
      expect(tester.takeException(), isNull);
    });

    testWidgets('converts non-string price to string for the price field', (
      tester,
    ) async {
      // OCR may extract price as a number; the form should convert it
      await _pumpTestApp(
        tester,
        WarrantyForm(initialData: {'price': 12500}),
      );

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['price']?.value, '12500');
      expect(tester.takeException(), isNull);
    });

    testWidgets('submits correct product when all initialData fields are present', (
      tester,
    ) async {
      Product? submittedProduct;
      final purchaseDate = DateTime(2024, 6, 20);

      await _pumpTestApp(
        tester,
        WarrantyForm(
          initialData: {
            'name': 'LG Refrigerator',
            'company': 'LG',
            'purchaseDate': purchaseDate,
            'warrantyPeriod': '3 Year',
            'category': 'Electronics and Appliances',
            'price': '35000',
            'purchasedAt': 'Reliance Digital',
            'salesPerson': 'Ramesh',
            'phone': '9000000001',
            'email': 'care@lg.com',
            'notes': 'Extended warranty card inside box',
          },
          onSave: (product) async {
            submittedProduct = product;
            return 'new-product-id';
          },
          onSaveSuccess: (_, __) {},
        ),
      );

      await tester.tap(_actionButtonFinder());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(submittedProduct, isNotNull);
      expect(submittedProduct!.name, 'LG Refrigerator');
      expect(submittedProduct!.company, 'LG');
      expect(submittedProduct!.purchaseDate, purchaseDate);
      expect(submittedProduct!.warrantyPeriod, '3 Year');
      expect(submittedProduct!.category, 'Electronics and Appliances');
      expect(submittedProduct!.price, 35000);
      expect(submittedProduct!.purchasedAt, 'Reliance Digital');
      expect(submittedProduct!.salesPerson, 'Ramesh');
      expect(submittedProduct!.phone, '9000000001');
      expect(submittedProduct!.email, 'care@lg.com');
      expect(submittedProduct!.notes, 'Extended warranty card inside box');
      expect(tester.takeException(), isNull);
    });

    testWidgets('tolerates partial initialData with only required fields', (
      tester,
    ) async {
      Product? submittedProduct;
      final purchaseDate = DateTime(2025, 3, 10);

      await _pumpTestApp(
        tester,
        WarrantyForm(
          initialData: {
            'name': 'Bosch Mixer',
            'company': 'Bosch',
            'purchaseDate': purchaseDate,
            'warrantyPeriod': '1 Year',
          },
          onSave: (product) async {
            submittedProduct = product;
            return 'partial-id';
          },
          onSaveSuccess: (_, __) {},
        ),
      );

      await tester.tap(_actionButtonFinder());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(submittedProduct, isNotNull);
      expect(submittedProduct!.name, 'Bosch Mixer');
      expect(submittedProduct!.company, 'Bosch');
      expect(submittedProduct!.warrantyPeriod, '1 Year');
      // Optional fields not in initialData should be null
      expect(submittedProduct!.price, isNull);
      expect(submittedProduct!.purchasedAt, isNull);
      expect(submittedProduct!.salesPerson, isNull);
      expect(submittedProduct!.phone, isNull);
      expect(submittedProduct!.email, isNull);
      expect(submittedProduct!.notes, isNull);
      expect(tester.takeException(), isNull);
    });

    // Regression: verify the old hardcoded category default 'Other' still works
    // now that it uses initialData?['category'] ?? 'Other'.
    testWidgets('regression: category still defaults to Other when initialData is empty map', (
      tester,
    ) async {
      await _pumpTestApp(
        tester,
        WarrantyForm(initialData: const {}),
      );

      final formState = tester.state<FormBuilderState>(
        find.byWidgetPredicate((widget) => widget is FormBuilder),
      );

      expect(formState.fields['category']?.value, 'Other');
      expect(tester.takeException(), isNull);
    });
  });

  group('WarrantyEditForm', () {
    testWidgets('updates preloaded values without optional images', (tester) async {
      Product? updatedProduct;

      await _pumpTestApp(
        tester,
        WarrantyEditForm(
          productId: 'existing-id',
          loadWarranty: (_) async => _existingWarrantyWithImages(),
          onUpdate: (product) async {
            updatedProduct = product;
          },
          onUpdateSuccess: (_, __) {},
        ),
      );

      await tester.tap(_actionButtonFinder());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(updatedProduct, isNotNull);
      expect(updatedProduct!.id, 'existing-id');
      expect(updatedProduct!.name, 'Electric coconut scraper');
      expect(updatedProduct!.company, 'Sowbaghya');
      expect(updatedProduct!.purchaseDate, DateTime(2026, 5, 3));
      expect(updatedProduct!.warrantyPeriod, '2 Year');
      expect(updatedProduct!.category, isNull);
      expect(updatedProduct!.price, 2500);
      expect(updatedProduct!.purchasedAt, 'Kodai Kondattam Maduravoyal');
      expect(updatedProduct!.productImage, isNull);
      expect(updatedProduct!.purchaseCopy, isNull);
      expect(updatedProduct!.warrantyCopy, isNull);
      expect(updatedProduct!.additionalImage, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpTestApp(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(1280, 2200));

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      fallbackLocale: defaultLocale,
      useFallbackTranslations: true,
      assetLoader: const _TestAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            builder: EasyLoading.init(),
            home: child,
          );
        },
      ),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

WarrantyWithImages _existingWarrantyWithImages() {
  final product = Product()
    ..id = 'existing-id'
    ..name = 'Electric coconut scraper'
    ..company = 'Sowbaghya'
    ..purchaseDate = DateTime(2026, 5, 3)
    ..warrantyPeriod = '2 Year'
    ..price = 2500
    ..purchasedAt = 'Kodai Kondattam Maduravoyal';

  return WarrantyWithImages(product, {});
}

Finder _actionButtonFinder() {
  return find.byWidgetPredicate((widget) => widget is ButtonStyleButton).last;
}

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'add_warranty': 'Add Warranty',
      'edit_warranty': 'Edit Warranty',
      'required': 'Required',
      'optional': 'Optional',
      'attachments': 'Attachments',
      'back': 'Back',
      'next': 'Next',
      'reset': 'Reset',
      'save': 'Save',
      'update': 'Update',
      'product_service_name': 'Product or service name',
      'brand_company': 'Brand or company',
      'purchase_date': 'Purchase date',
      'warranty_period': 'Warranty period',
      'category': 'Category',
      'price': 'Price',
      'where_did_you_purchase': 'Where did you purchase',
      'purchased_at': 'Purchased at',
      'do_you_know_contact_person_name': 'Contact person',
      'contact_person_name': 'Contact person name',
      'customer_care_phone': 'Customer care phone',
      'support_phone': 'Support phone',
      'customer_care_email': 'Customer care email',
      'support_email': 'Support email',
      'additional_information': 'Additional information',
      'quick_note': 'Quick note',
      'upload_product_image': 'Upload product image',
      'upload_purchase_bill_image': 'Upload purchase bill image',
      'upload_warranty_image': 'Upload warranty image',
      'other_image': 'Other image',
      'toast.save_success': 'Saved successfully',
      'toast.failed_to_save': 'Failed to save',
    };
  }
}

void _fillWarrantyForm(
  WidgetTester tester, {
  required String name,
  required String company,
  required DateTime purchaseDate,
  required String warrantyPeriod,
  required String category,
  required String price,
  required String purchasedAt,
}) {
  final formState = tester.state<FormBuilderState>(
    find.byWidgetPredicate((widget) => widget is FormBuilder),
  );

  formState.fields['name']?.didChange(name);
  formState.fields['company']?.didChange(company);
  formState.fields['purchaseDate']?.didChange(purchaseDate);
  formState.fields['warrantyPeriod']?.didChange(warrantyPeriod);
  formState.fields['category']?.didChange(category);
  formState.fields['price']?.didChange(price);
  formState.fields['purchasedAt']?.didChange(purchasedAt);
}
