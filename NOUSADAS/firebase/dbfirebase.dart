import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkNewContent() async {
  final snap = await FirebaseFirestore.instance
      .collection("LSM_content")
      .doc("global")
      .get();

  return snap.data()?["abecedario_actualizado"] ?? false;
}
