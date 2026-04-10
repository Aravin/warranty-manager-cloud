import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_manager_cloud/shared/string_functions.dart';

void main() {
  group('string_functions', () {
    test('isEmptyString returns true only for empty strings', () {
      expect(isEmptyString(''), isTrue);
      expect(isEmptyString('hello'), isFalse);
    });

    test('emptyStringPlaceholder falls back only for empty values', () {
      expect(emptyStringPlaceholder('', 'N/A'), 'N/A');
      expect(emptyStringPlaceholder('Item', 'N/A'), 'Item');
    });
  });
}
