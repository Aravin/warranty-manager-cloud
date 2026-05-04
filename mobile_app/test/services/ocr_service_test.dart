import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_manager_cloud/services/ocr_service.dart';

void main() {
  group('OcrService.parseReceiptText', () {
    test('maps structured receipt details into matching form fields', () {
      final data = OcrService().parseReceiptText(_structuredReceiptText);

      expect(data['name'], 'Mixer Grinder 750W');
      expect(data['company'], 'Sathya Electronics');
      expect(data['purchaseDate'], DateTime(2026, 5, 3));
      expect(data['warrantyPeriod'], '2 Year');
      expect(data['price'], '2500');
      expect(data['purchasedAt'], 'No. 12, Anna Salai, Chennai');
      expect(data['phone'], '044 2345 6789');
      expect(data['email'], 'support@sathya.example');
      expect(data['notes'], contains('OCR SCANNED RECEIPT DATA'));
    });

    test('keeps notes and skips unsupported fields for loose OCR text', () {
      final data = OcrService().parseReceiptText(_minimalReceiptText);

      expect(data['company'], 'Fresh Mart');
      expect(data['price'], '149.50');
      expect(data['purchaseDate'], isNull);
      expect(data['warrantyPeriod'], isNull);
      expect(data['phone'], isNull);
      expect(data['email'], isNull);
      expect(data['notes'], contains(_minimalReceiptText.trim()));
    });

    test('prefers labelled total and parses textual dates and salesperson', () {
      final data = OcrService().parseReceiptText(_textualDateReceiptText);

      expect(data['company'], 'Mega Appliances');
      expect(data['name'], 'Air Fryer XL');
      expect(data['purchaseDate'], DateTime(2026, 5, 4));
      expect(data['salesPerson'], 'Priya');
      expect(data['warrantyPeriod'], '1 Year');
      expect(data['price'], '9999');
    });
  });
}

const _structuredReceiptText = '''
Sathya Electronics
No. 12, Anna Salai
Chennai
Phone: 044 2345 6789
Email: support@sathya.example
Date: 03/05/2026
Item: Mixer Grinder 750W
Warranty: 2 Year
Grand Total: 2500.00
''';

const _minimalReceiptText = '''
Fresh Mart
Receipt #2048
Bread 49.50
Milk 100.00
Total 149.50
''';

const _textualDateReceiptText = '''
Mega Appliances
Model: Air Fryer XL
Sold By: Priya
Date: 4 May 2026
MRP 12000.00
Amount Paid: 9999.00
1 Year Warranty
''';