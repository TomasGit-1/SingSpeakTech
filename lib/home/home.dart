import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sing_speak_tech/controller/download_firebase.dart';
import 'package:sing_speak_tech/home/menu_home.dart';
import 'package:sing_speak_tech/views/abc_view.dart';

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

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

  Future<void> _checkIfDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      downloaded = prefs.getBool("abecedario_downloaded") ?? false;
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      isDownloading = true;
      current = 0;
      total = 1;
    });

    total = await ImageDownloader.getTotalFiles();

    await ImageDownloader.downloadAllImagesOnce(
      onProgress: (c, t) {
        setState(() {
          current = c;
          total = t;
        });
      },
    );

    await _checkIfDownloaded(); // actualiza el flag

    setState(() {
      isDownloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        elevation: 10,
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: MenuHome(
              downloaded: downloaded,
              onDownloadTap: _startDownload,
              onAbecedarioTap: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AbecedarioPage()),
                  );
              },
              onNumerosTap: () {},
              onColoresTap: () {},
            ),
          ),
          if (isDownloading && !downloaded) ...[
            const SizedBox(height: 30),
            SizedBox(
              width: 250,
              child: LinearProgressIndicator(
                value:
                    (current > 0 && total > 0)
                        ? (current / total).clamp(0.0, 1.0)
                        : 0.0,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${((current / total) * 100).clamp(0.0, 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
      // Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Text("Bienvenido, ${user?.displayName}"),
      //         Text(user?.email ?? ""),
      //         const SizedBox(height: 40),

      //         if (!isDownloading)
      //           ElevatedButton(
      //             onPressed: _startDownload,
      //             child: const Text("Descargar contenido"),
      //           ),

      // ],
      //     ),
      //   ),
    );
  }
}
