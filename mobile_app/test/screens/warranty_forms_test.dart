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

  group('WarrantyEditForm', () {
    testWidgets('updates preloaded values without optional images', (
      tester,
    ) async {
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
