import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sing_speak_tech/home/menu_home.dart';
import 'package:sing_speak_tech/controller/resource_downloader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDownloading = false;
  int current = 0;
  int total = 1;
  bool downloaded = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

  Future<void> _checkIfDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      downloaded = prefs.getBool("lsm_resources_downloaded") ?? false;
    });
  }

  Future<void> _startDownload() async {
    if (isDownloading) return;
    
    setState(() {
      isDownloading = true;
      current = 0;
      total = 1;
    });

    // 🔥 1. Obtener tamaño total en bytes
    final bytes = await ResourceDownloader.getTotalBytes();
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("Se descargarán aproximadamente $mb MB"),
    //     duration: const Duration(seconds: 3),
    //   ),
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content:  Row(
          children: [
            SizedBox(width: 12),
            Text("Se descargarán aproximadamente $mb MB", style: TextStyle(fontSize: 16)),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    // 🔥 2. Número de archivos para el progreso
    total = await ResourceDownloader.getTotalFiles();

    // 🔥 3. Descargar realmente
    await ResourceDownloader.downloadAllResources(
      onProgress: (c, t) {
        setState(() {
          current = c;
          total = t;
        });
      },
    );

    await _checkIfDownloaded();

    setState(() {
      isDownloading = false;
    });

    _showDownloadSnackBar();
  }

  void _showDownloadSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 12),
            Text("Descarga completa", style: TextStyle(fontSize: 16)),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<BottomNavigationBarItem> _navItems(bool downloaded) {
    if (!downloaded) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download, size: 30),
          label: "Descargar",
        ),
      ];
    }

    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home, size: 30),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.school, size: 30),
        label: "Aprender",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.play_circle_fill, size: 30),
        label: "Juegos",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.download, size: 30),
        label: "Descargar",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people, size: 30),
        label: "Perfil",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("LSM", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),

      body: _getPage(),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFF98A76),
            elevation: 100,
            selectedItemColor: const Color(0xFF0D1B2A),
            unselectedItemColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedFontSize: 12,
            unselectedFontSize: 0,

            currentIndex: index,
            items: _navItems(downloaded),

            onTap: (i) async {
              // Antes de descargar → solo Home y Descargar funcionan
              if (!downloaded) {
                if (i == 1) {
                  setState(() => index = i);
                  _startDownload();
                } else {
                  setState(() => index = 1);
                }
                return;
              }

              // Después → App normal
              setState(() => index = i);
            },
          ),
        ),
      ),
    );
  }

  Widget _getPage() {
    if (!downloaded) {
      return _buildDownloadView();
    }

    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Usuario';

    switch (index) {
      case 0: return const HomeMenu();
      case 1: return _placeholderView("Aprender");
      case 2: return _placeholderView("Juegos");
      case 3: return _buildDownloadView();
      case 4: return _placeholderView(name);
    }

    return Container();
  }

  Widget _buildDownloadView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDownloading) ...[
            const Icon(Icons.downloading, size: 90, color: Colors.white),
            const SizedBox(height: 20),
            const Text("Descargando contenido...",
                style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 20),

            SizedBox(
              width: 260,
              child: LinearProgressIndicator(
                value: total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "${((current / total) * 100).clamp(0.0, 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],

          if (!isDownloading && downloaded)
            const Text("Contenido descargado ✔",
                style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _placeholderView(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }
}
