import 'package:flutter/material.dart';
import 'package:sing_speak_tech/views/detect_photo_page.dart';

class MenuHome extends StatelessWidget {
  final bool downloaded;
  final VoidCallback onDownloadTap;
  final VoidCallback onAbecedarioTap;
  final VoidCallback onNumerosTap;
  final VoidCallback onColoresTap;

  const MenuHome({
    super.key,
    required this.downloaded,
    required this.onDownloadTap,
    required this.onAbecedarioTap,
    required this.onNumerosTap,
    required this.onColoresTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
        children: [
          _MenuTile(
            icon: Icons.sort_by_alpha,
            label: "Abecedario",
            color: const Color(0xFFFFF2C9),
            enabled: downloaded,
            onTap: downloaded ? onAbecedarioTap : null,
          ),
          _MenuTile(
            icon: Icons.looks_one,
            label: "Números",
            color: const Color(0xFFE0F7FA),
            enabled: downloaded,
            onTap: downloaded ? onNumerosTap : null,
          ),
          _MenuTile(
            icon: Icons.palette,
            label: "Colores",
            color: const Color(0xFFEDE7F6),
            enabled: downloaded,
            onTap: downloaded ? onColoresTap : null,
          ),
          _MenuTile(
            icon: Icons.download,
            label: "Descargar\ncontenido",
            color: const Color(0xFFFFE0E0),
            enabled: true,
            onTap: onDownloadTap,
          ),

          _MenuTile(
            icon: Icons.camera_alt,
            label: "Abrir Cámara (YOLO)",
            color: const Color(0xFFD1FFC6),
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPhotoYoloView()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4, // se ve gris si está deshabilitado
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null, // deshabilita el tap
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
