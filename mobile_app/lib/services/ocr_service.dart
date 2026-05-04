import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

class OcrScanResult {
  final Map<String, dynamic>? data;
  final bool wasCancelled;
  final String? errorMessage;

  const OcrScanResult.success(this.data)
      : wasCancelled = false,
        errorMessage = null;

  const OcrScanResult.cancelled()
      : data = null,
        wasCancelled = true,
        errorMessage = null;

  const OcrScanResult.failed([this.errorMessage])
      : data = null,
        wasCancelled = false;

  bool get hasData => data != null && data!.isNotEmpty;
}

class OcrService {
  final ImagePicker _picker = ImagePicker();

  static final RegExp _moneyRegex = RegExp(
    r'(?<!\d)(\d{1,3}(?:,\d{3})*|\d+)(?:\.(\d{2}))',
    caseSensitive: false,
  );
  static final RegExp _dayFirstDateRegex = RegExp(
    r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})\b',
  );
  static final RegExp _yearFirstDateRegex = RegExp(
    r'\b(\d{4})[-/](\d{1,2})[-/](\d{1,2})\b',
  );
  static final RegExp _textualDateRegex = RegExp(
    r'\b(\d{1,2})\s+'
    r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)'
    r'\s+(\d{2,4})\b',
    caseSensitive: false,
  );
  static final RegExp _emailRegex = RegExp(
    r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b',
  );
  static final RegExp _phoneRegex = RegExp(
    r'(?:(?:\+?\d{1,3}[\s-]?)?(?:\(?\d{2,4}\)?[\s-]?){2,}\d{3,4})',
  );
  static final RegExp _warrantyRegex = RegExp(
    r'(\d{1,2})\s*(month|months|year|years)\s*warranty|'
    r'warranty(?:\s+period)?\s*[:\-]?\s*(\d{1,2})\s*(month|months|year|years)',
    caseSensitive: false,
  );

  @visibleForTesting
  Map<String, dynamic> parseReceiptText(String text) => _parseReceipt(text);

  Future<OcrScanResult> scanReceiptAndExtract(
      {ImageSource source = ImageSource.camera}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return const OcrScanResult.cancelled();

      EasyLoading.show(status: 'Parsing Receipt...');

      final rawText = await _recognizeText(image.path);

      if (rawText.trim().isEmpty) {
        return const OcrScanResult.failed(
            'Failed to scan receipt or no text found.');
      }

      return OcrScanResult.success(_parseReceipt(rawText));
    } catch (e) {
      debugPrint("OCR Error: $e");
      return const OcrScanResult.failed(
          'Failed to scan receipt or no text found.');
    }
  }

  Future<OcrScanResult> scanDocumentExplorerAndExtract() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return const OcrScanResult.cancelled();
      }

      EasyLoading.show(status: 'Parsing Document...');

      final extension = result.files.single.extension?.toLowerCase();
      String imagePath = result.files.single.path!;

      if (!['pdf', 'png', 'jpg', 'jpeg'].contains(extension)) {
        return const OcrScanResult.failed(
            'Unsupported file type. Please upload a PDF or Image.');
      }

      if (extension == 'pdf') {
        final document = await PdfDocument.openFile(imagePath);
        final page = await document.getPage(1);
        final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );

        if (pageImage == null) {
          await page.close();
          await document.close();
          return const OcrScanResult.failed('Failed to read the selected PDF.');
        }

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/ocr_temp_pdf.png');
        await tempFile.writeAsBytes(pageImage.bytes);

        await page.close();
        await document.close();

        imagePath = tempFile.path;
      }

      final rawText = await _recognizeText(imagePath);

      if (rawText.trim().isEmpty) {
        return const OcrScanResult.failed(
            'Failed to scan document or no text found.');
      }

      return OcrScanResult.success(_parseReceipt(rawText));
    } catch (e) {
      debugPrint("Document Explorer OCR Error: $e");
      return const OcrScanResult.failed(
          'Failed to scan document or no text found.');
    }
  }

  Future<String> _recognizeText(String imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      textRecognizer.close();
    }
  }

  Map<String, dynamic> _parseReceipt(String text) {
    final lines = text
        .split('\n')
        .map(_cleanLine)
        .where((line) => line.isNotEmpty)
        .toList();

    final Map<String, dynamic> data = {
      'notes':
          '--- OCR SCANNED RECEIPT DATA ---\n\n$text\n\n------------------------',
    };

    final company = _extractCompany(lines);
    if (company != null) {
      data['company'] = company;
    }

    final name = _extractProductName(lines, company: company);
    if (name != null) {
      data['name'] = name;
    }

    final purchaseDate = _extractPurchaseDate(text);
    if (purchaseDate != null) {
      data['purchaseDate'] = purchaseDate;
    }

    final price = _extractPrice(text, lines);
    if (price != null) {
      data['price'] = price;
    }

    final purchasedAt = _extractPurchaseLocation(lines, company: company);
    if (purchasedAt != null) {
      data['purchasedAt'] = purchasedAt;
    }

    final phone = _extractPhone(text);
    if (phone != null) {
      data['phone'] = phone;
    }

    final email = _extractEmail(text);
    if (email != null) {
      data['email'] = email;
    }

    final salesPerson = _extractSalesPerson(lines);
    if (salesPerson != null) {
      data['salesPerson'] = salesPerson;
    }

    final warrantyPeriod = _extractWarrantyPeriod(text);
    if (warrantyPeriod != null) {
      data['warrantyPeriod'] = warrantyPeriod;
    }

    return data;
  }

  String _cleanLine(String line) {
    return line.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _extractCompany(List<String> lines) {
    for (final line in lines.take(6)) {
      if (_isMetadataLine(line) || _looksLikeAddress(line)) {
        continue;
      }
      if (_containsLetters(line) && line.length >= 3) {
        return line;
      }
    }

    return null;
  }

  String? _extractProductName(List<String> lines, {String? company}) {
    for (final line in lines) {
      final match = RegExp(
        r'^(?:item|product|description|model|service)\s*[:\-]\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }

    final candidates = <String>[];
    for (final line in lines) {
      if (line == company || _isMetadataLine(line) || _looksLikeAddress(line)) {
        continue;
      }
      if (!_containsLetters(line) || line.length < 4 || line.length > 80) {
        continue;
      }
      if (RegExp(r'\b(qty|qty\.|quantity|gst|invoice|receipt|order|bill)\b', caseSensitive: false)
          .hasMatch(line)) {
        continue;
      }
      candidates.add(line);
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  DateTime? _extractPurchaseDate(String text) {
    final yearFirstMatch = _yearFirstDateRegex.firstMatch(text);
    if (yearFirstMatch != null) {
      return _safeDate(
        int.tryParse(yearFirstMatch.group(1)!),
        int.tryParse(yearFirstMatch.group(2)!),
        int.tryParse(yearFirstMatch.group(3)!),
      );
    }

    final dayFirstMatch = _dayFirstDateRegex.firstMatch(text);
    if (dayFirstMatch != null) {
      final day = int.tryParse(dayFirstMatch.group(1)!);
      final month = int.tryParse(dayFirstMatch.group(2)!);
      final yearText = dayFirstMatch.group(3)!;
      final year = int.tryParse(
        yearText.length == 2 ? '20$yearText' : yearText,
      );
      return _safeDate(year, month, day);
    }

    final textualDateMatch = _textualDateRegex.firstMatch(text);
    if (textualDateMatch == null) {
      return null;
    }

    final day = int.tryParse(textualDateMatch.group(1)!);
    final month = _monthNumber(textualDateMatch.group(2)!);
    final yearText = textualDateMatch.group(3)!;
    final year = int.tryParse(yearText.length == 2 ? '20$yearText' : yearText);
    return _safeDate(year, month, day);
  }

  String? _extractPrice(String text, List<String> lines) {
    final totalLine = lines.firstWhere(
      (line) => RegExp(
        r'\b(grand total|total amount|amount due|amount paid|net amount|total)\b',
        caseSensitive: false,
      ).hasMatch(line),
      orElse: () => '',
    );

    final preferredAmount = _highestAmount(totalLine);
    if (preferredAmount != null) {
      return preferredAmount;
    }

    return _highestAmount(text);
  }

  String? _extractPurchaseLocation(List<String> lines, {String? company}) {
    final locationLines = <String>[];

    for (final line in lines) {
      if (line == company || _isMetadataLine(line)) {
        continue;
      }
      if (_looksLikeAddress(line)) {
        locationLines.add(line);
        continue;
      }
      if (locationLines.isNotEmpty &&
          _containsLetters(line) &&
          !RegExp(r'\d').hasMatch(line) &&
          line.split(' ').length <= 4) {
        locationLines.add(line);
      }
      if (locationLines.length == 2) {
        break;
      }
    }

    if (locationLines.isEmpty) {
      return null;
    }

    return locationLines.join(', ');
  }

  String? _extractPhone(String text) {
    for (final match in _phoneRegex.allMatches(text)) {
      final value = match.group(0)?.replaceAll(RegExp(r'\s+'), ' ').trim();
      final digitCount = value?.replaceAll(RegExp(r'\D'), '').length ?? 0;
      if (value != null && digitCount >= 8 && digitCount <= 15) {
        return value;
      }
    }

    return null;
  }

  String? _extractEmail(String text) {
    return _emailRegex.firstMatch(text)?.group(0);
  }

  String? _extractSalesPerson(List<String> lines) {
    for (final line in lines) {
      final match = RegExp(
        r'^(?:sales\s*person|sold\s*by|cashier|served\s*by)\s*[:\-]\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }

    return null;
  }

  String? _extractWarrantyPeriod(String text) {
    final match = _warrantyRegex.firstMatch(text);
    if (match == null) {
      return null;
    }

    final value = match.group(1) ?? match.group(3);
    final unit = (match.group(2) ?? match.group(4))?.toLowerCase();
    if (value == null || unit == null) {
      return null;
    }

    final count = int.tryParse(value);
    if (count == null) {
      return null;
    }

    final normalized = '$count ${unit.startsWith('year') ? 'Year' : 'Month'}';
    return kWarrantyPeriods.contains(normalized) ? normalized : null;
  }

  bool _containsLetters(String text) {
    return RegExp(r'[A-Za-z]').hasMatch(text);
  }

  bool _isMetadataLine(String line) {
    return RegExp(
      r'\b(invoice|receipt|bill|gst|tax|date|time|total|subtotal|amount|cash|card|upi|qty|quantity|item\s+count|balance|change|phone|mobile|email|warranty)\b',
      caseSensitive: false,
    ).hasMatch(line);
  }

  bool _looksLikeAddress(String line) {
    return RegExp(
      r'\b(no\.?|street|st\.?|road|rd\.?|avenue|ave\.?|lane|ln\.?|nagar|salai|city|state|pin|pincode|zip|mall|plaza|market|branch|floor|shop|near)\b',
      caseSensitive: false,
    ).hasMatch(line);
  }

  String? _highestAmount(String text) {
    double? highest;

    for (final match in _moneyRegex.allMatches(text)) {
      final whole = match.group(1)?.replaceAll(',', '');
      final decimal = match.group(2);
      final amount = double.tryParse('$whole.$decimal');
      if (amount == null) {
        continue;
      }
      if (highest == null || amount > highest) {
        highest = amount;
      }
    }

    if (highest == null || highest <= 0) {
      return null;
    }

    return highest == highest.roundToDouble()
        ? highest.toStringAsFixed(0)
        : highest.toStringAsFixed(2);
  }

  DateTime? _safeDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) {
      return null;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  int? _monthNumber(String value) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    return months[value.toLowerCase().substring(0, 3)];
  }
}
