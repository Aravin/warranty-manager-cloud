import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:warranty_manager_cloud/services/auth.dart';

final storage = FirebaseStorage.instance;
final storageRef = storage.ref();

Future<void> storeImage(File file) async {
  // product image
  final imgRef = storageRef.child(USER_ID + '/' + basename(file.path));
  await imgRef.putFile(file);
}
