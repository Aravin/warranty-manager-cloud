import 'package:cross_file/cross_file.dart';

XFile? parseFormImageValue(dynamic value) {
  if (value is! List || value.isEmpty) {
    return null;
  }

  final image = value.first;
  if (image is String) {
    return XFile(image);
  }

  return image is XFile ? image : null;
}