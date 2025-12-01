import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sing_speak_tech/controller/resource_downloader.dart';
import 'package:sing_speak_tech/views/abc_view.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  Future<File?> _loadLocalIcon(String folder, String fileName) async {
    final file = await ResourceDownloader.getLocalFile(folder, fileName);

    print("🔍 Buscando icono: $folder/$fileName");
    if (file != null) {
      print("✅ Icono encontrado");
      return file;
    }

    print("❌ Icono NO encontrado");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1 / 1.2,
        children: [
          FutureBuilder<File?>(
            future: _loadLocalIcon("resources", "abecedario_icono.png"),
            builder: (context, snapshot) {
              return _MenuTile(
                localIcon: snapshot.data,
                label: "Abecedario",
                color: Color(0xFFFFFFFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AbecedarioPage()),
                  );
                },
              );
            },
          ),

          FutureBuilder<File?>(
            future: _loadLocalIcon("resources", "numeros_icono.png"),
            builder: (context, snapshot) {
              return _MenuTile(
                localIcon: snapshot.data,
                label: "Números",
                color: Color(0xFFFFFFFF),
                onTap: () {},
              );
            },
          ),

          FutureBuilder<File?>(
            future: _loadLocalIcon("resources", "colores_icono.png"),
            builder: (context, snapshot) {
              return _MenuTile(
                localIcon: snapshot.data,
                label: "Colores",
                color: Color.fromARGB(255, 255, 255, 255),
                onTap: () {},
              );
            },
          ),

        ],
      ),
    );
  }
}


class _MenuTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final File? localIcon;

  const _MenuTile({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    required this.localIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: localIcon != null
                  ? Image.file(localIcon!, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 70, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
