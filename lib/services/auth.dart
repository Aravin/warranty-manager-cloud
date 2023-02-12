import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final USER_ID = auth.currentUser?.uid ?? 'test';
