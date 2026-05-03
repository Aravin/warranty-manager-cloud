import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
    Map<String, dynamic> data = {
      'notes':
          '--- OCR SCANNED RECEIPT DATA ---\n\n$text\n\n------------------------',
    };

    RegExp moneyRegex = RegExp(r'\$?\s?(\d{1,5}\.\d{2})');
    var moneyMatches = moneyRegex.allMatches(text);
    if (moneyMatches.isNotEmpty) {
      double highest = 0.0;
      for (var m in moneyMatches) {
        double? val = double.tryParse(m.group(1) ?? '0');
        if (val != null && val > highest) highest = val;
      }
      if (highest > 0) data['price'] = highest.toString();
    }

    RegExp dateRegex = RegExp(r'(\d{2}[-/]\d{2}[-/]\d{2,4})');
    var dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      try {
        final dStr = dateMatch.group(1)!.replaceAll('-', '/');
        final parts = dStr.split('/');
        final d = parts[0];
        final m = parts[1];
        final y = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
        data['purchaseDate'] =
            DateTime(int.parse(y), int.parse(m), int.parse(d));
      } catch (e) {
        debugPrint("Date parse fail");
      }
    }

    List<String> lines = text.split('\n');
    for (var line in lines) {
      final l = line.trim();
      if (l.isNotEmpty && l.length > 2 && !l.contains(RegExp(r'\d'))) {
        data['company'] = l;
        break;
      }
    }

    return data;
  }
}
