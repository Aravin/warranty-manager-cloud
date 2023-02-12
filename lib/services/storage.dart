import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:warranty_manager_cloud/services/auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final storage = FirebaseStorage.instance;
final storageRef = storage.ref();

Future<void> storeImage(String filename, File file) async {
  final imgRef = storageRef.child(USER_ID + '/' + filename);
  final tempImgPath = '${file.absolute.parent.path}/temp.jpg';
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    tempImgPath,
    format: CompressFormat.jpeg,
    minHeight: 720,
    minWidth: 720,
  );
  await imgRef.putFile(compressedFile!);
  await File(tempImgPath).delete();
}
