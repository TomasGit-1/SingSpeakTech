import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ResourceDownloader {
  static const String flag = "lsm_resources_downloaded";

  /// Carpetas esperadas en Firebase y local
  static const List<String> folders = ["abecedario", "resources", "Models"];

  /// Cuenta la cantidad de archivos en Firebase
  static Future<int> getTotalFiles() async {
    int total = 0;

    for (final folder in folders) {
      final list = await FirebaseStorage.instance.ref(folder).listAll();
      total += list.items.length;
    }

    return total;
  }

  /// Descarga TODO el contenido organizado por carpetas
  static Future<void> downloadAllResources({
    required Function(int current, int total) onProgress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyDownloaded = prefs.getBool(flag) ?? false;

    // Si ya se descargó → no bajar de nuevo
    if (alreadyDownloaded) {
      final total = await getTotalFiles();
      onProgress(total, total);
      return;
    }

    int current = 0;
    final total = await getTotalFiles();
    final baseDir = await getApplicationDocumentsDirectory();

    for (final folder in folders) {
      final storageRef = FirebaseStorage.instance.ref(folder);
      final list = await storageRef.listAll();

      // Crear carpeta local
      final localFolder = Directory("${baseDir.path}/$folder");
      if (!await localFolder.exists()) {
        await localFolder.create(recursive: true);
      }

      for (final item in list.items) {
        final url = await item.getDownloadURL();
        final localPath = "${localFolder.path}/${item.name}";

        await Dio().download(url, localPath);

        current++;
        onProgress(current, total);
      }
    }

    await prefs.setBool(flag, true);
  }

  /// Obtiene el archivo descargado de: /carpeta/nombre.png
  static Future<File?> getLocalFile(String folder, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$folder/$fileName";
    final file = File(path);

    return (await file.exists()) ? file : null;
  }

  /// 🔥 NECESARIO PARA TU HomeMenu
  /// Detecta automáticamente la carpeta en base al nombre del archivo
  static Future<String> getLocalFilePath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();

    String folder = "";

    if (fileName.contains("abecedario"))
      folder = "resources";
    else if (fileName.contains("numeros"))
      folder = "resources";
    else if (fileName.contains("colores"))
      folder = "resources";
    else if (fileName.endsWith(".tflite"))
      folder = "Models";
    else if (fileName.length == 1 || fileName.contains("_"))
      folder = "abecedario";

    // Path final
    return "${dir.path}/$folder/$fileName";
  }

  /// Carga todas las carpetas locales devueltas por downloadAllResources()
  static Future<Map<String, List<File>>> loadAllLocalFolders() async {
    final dir = await getApplicationDocumentsDirectory();
    final baseDir = Directory(dir.path);

    if (!await baseDir.exists()) return {};

    final Map<String, List<File>> foldersMap = {};

    for (final entry in baseDir.listSync()) {
      if (entry is Directory) {
        final folderName = entry.path.split("/").last;

        final files =
            entry
                .listSync()
                .where(
                  (f) =>
                      f.path.endsWith(".png") ||
                      f.path.endsWith(".jpg") ||
                      f.path.endsWith(".jpeg") ||
                      f.path.endsWith(".webp") ||
                      f.path.endsWith(".tflite") ||
                      f.path.endsWith(".txt"),
                )
                .map((f) => File(f.path))
                .toList();

        foldersMap[folderName] = files;
      }
    }

    return foldersMap;
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
