import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ResourceDownloader {
  static const String flag = "lsm_resources_downloaded";

  static Future<int> getTotalFiles() async {
    int total = 0;
    final folders = ["abecedario", "resources", "Models"];

    for (final folder in folders) {
      final list = await FirebaseStorage.instance.ref(folder).listAll();
      total += list.items.length;
    }

    return total;
  }

  static Future<void> downloadAllResources({
    required Function(int current, int total) onProgress,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(flag) == true) {
      final total = await getTotalFiles();
      onProgress(total, total);
      return;
    }

    int current = 0;
    final total = await getTotalFiles();

    final baseDir = await getApplicationDocumentsDirectory();
    print("📂 Carpeta base local: ${baseDir.path}");

    final folders = ["abecedario", "resources", "Models"];

    for (final folder in folders) {
      final ref = FirebaseStorage.instance.ref(folder);
      final list = await ref.listAll();

      for (final item in list.items) {
        final String fullPath = item.fullPath;   // EJ: "abecedario/A.png"
        final String localPath = p.join(baseDir.path, fullPath);

        print("➡️ Archivo a descargar: $fullPath");
        print("📌 Ruta local destino: $localPath");

        final File file = File(localPath);

        // 🚨 ESTE ES EL TRUCO: crear TODAS las subcarpetas correctamente
        await Directory(p.dirname(localPath)).create(recursive: true);

        final url = await item.getDownloadURL();
        await Dio().download(url, localPath);

        print("✅ Guardado correctamente en carpeta");

        current++;
        onProgress(current, total);
      }
    }

    print("🎉 TODAS las carpetas y archivos se descargaron correctamente");
    await prefs.setBool(flag, true);
  }

  static Future<File?> getLocalFile(String folder, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$folder/$fileName";

    final file = File(path);
    return file.existsSync() ? file : null;
  }

  
  static Future<int> getTotalBytes() async {
    int totalBytes = 0;

    final folders = ["abecedario", "resources", "Models"];

    for (final folder in folders) {
      final storageRef = FirebaseStorage.instance.ref(folder);
      final list = await storageRef.listAll();

      for (final item in list.items) {
        final meta = await item.getMetadata();
        totalBytes += meta.size ?? 0;
      }
    }

    return totalBytes;
  }
}
