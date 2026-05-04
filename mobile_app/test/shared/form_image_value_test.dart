import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_manager_cloud/shared/form_image_value.dart';

void main() {
  group('parseFormImageValue', () {
    test('returns null for null input', () {
      expect(parseFormImageValue(null), isNull);
    });

    test('returns null for non-list input', () {
      expect(parseFormImageValue('not-a-list'), isNull);
      expect(parseFormImageValue(1), isNull);
      expect(parseFormImageValue({'path': '/tmp/image.png'}), isNull);
    });

    test('returns null for an empty list', () {
      expect(parseFormImageValue(<dynamic>[]), isNull);
    });

    test('converts a string path into an XFile', () {
      final image = parseFormImageValue(<dynamic>['/tmp/product.png']);

      expect(image, isNotNull);
      expect(image!.path, '/tmp/product.png');
    });

    test('returns the same XFile instance when already provided', () {
      final file = XFile('/tmp/bill.png');
      final image = parseFormImageValue(<dynamic>[file]);

      expect(image, same(file));
    });

    test('uses the first list item when multiple values are present', () {
      final image = parseFormImageValue(
        <dynamic>['/tmp/first.png', '/tmp/second.png'],
      );

      expect(image, isNotNull);
      expect(image!.path, '/tmp/first.png');
    });

    test('returns null for unsupported list item types', () {
      expect(parseFormImageValue(<dynamic>[42]), isNull);
      expect(parseFormImageValue(<dynamic>[true]), isNull);
      expect(parseFormImageValue(<dynamic>[{'path': '/tmp/image.png'}]), isNull);
    });
  });
}