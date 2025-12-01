import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AbecedarioPage extends StatefulWidget {
  const AbecedarioPage({super.key});

  @override
  State<AbecedarioPage> createState() => _AbecedarioPageState();
}

class _AbecedarioPageState extends State<AbecedarioPage> {
  List<File> images = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAbecedarioImages();
  }

  Future<void> _loadAbecedarioImages() async {
    final dir = await getApplicationDocumentsDirectory();

    final abcDir = Directory("${dir.path}/abecedario");

    print("📁 Buscando imágenes en: ${abcDir.path}");

    if (!await abcDir.exists()) {
      print("❌ No existe la carpeta abecedario");
      setState(() => loading = false);
      return;
    }

    final files =
        abcDir
            .listSync()
            .where(
              (f) =>
                  f.path.endsWith(".png") ||
                  f.path.endsWith(".jpg") ||
                  f.path.endsWith(".jpeg"),
            )
            .map((f) => File(f.path))
            .toList();

    // Ordenar por nombre
    files.sort((a, b) => a.path.compareTo(b.path));

    setState(() {
      images = files;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("LSM", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(
          color: Colors.white, 
          size: 28, 
        ),
      ),

      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : images.isEmpty
              ? const Center(
                child: Text(
                  "No hay imágenes descargadas",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1 / 1.2,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final img = images[index];
                  // Extraer nombre limpio
                  String name = img.path.split("/").last.split(".").first;

                  if (name.startsWith("abecedario_")) {
                    name = name.replaceFirst("abecedario_", "");
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(img, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
