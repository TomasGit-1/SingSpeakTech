import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageDownloader {
  static const String firestoreDocId = "contenido_abc";

  static Future<int> getTotalFiles() async {
    final storageRef = FirebaseStorage.instance.ref().child("abecedario");
    final list = await storageRef.listAll();
    return list.items.length;
  }

  static Future<void> downloadAllImagesOnce({
    required Function(int current, int total) onProgress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getBool("abecedario_downloaded") ?? false;

    final storageRef = FirebaseStorage.instance.ref().child("abecedario");
    final list = await storageRef.listAll();

    int total = list.items.length;
    int current = 0;

    if (downloaded) {
      onProgress(total, total);
      return;
    }

    final dir = await getApplicationDocumentsDirectory();

    for (final item in list.items) {
      final url = await item.getDownloadURL();
      final localPath = "${dir.path}/${item.name}";
      await Dio().download(url, localPath);

      current++;
      onProgress(current, total);
    }

    await prefs.setBool("abecedario_downloaded", true);

    // await updateFirestoreAfterDownload();
  }

  static Future<void> updateFirestoreAfterDownload() async {
    await FirebaseFirestore.instance
        .collection("LSM_content")
        .doc(firestoreDocId)
        .update({"abecedarios_new_content": false});
  }

  static Stream<DocumentSnapshot> getFirestoreStream() {
    FirebaseFirestore.instance.collection("LSM_content").get().then((query) {
      print("📌 DOCUMENTOS EN LSM_content:");
      for (var doc in query.docs) {
        print("   → ${doc.id}");
      }
    });

    Stream<DocumentSnapshot> data =
        FirebaseFirestore.instance
            .collection("LSM_content")
            .doc(firestoreDocId)
            .snapshots();
    return data;
  }
}
