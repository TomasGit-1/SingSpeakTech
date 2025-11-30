import 'package:flutter/material.dart';

class FloatingBottomBarDemo extends StatefulWidget {
  const FloatingBottomBarDemo({super.key});

  @override
  State<FloatingBottomBarDemo> createState() => _FloatingBottomBarDemoState();
}

class _FloatingBottomBarDemoState extends State<FloatingBottomBarDemo> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFFF98A76),
            elevation: 10,
            selectedItemColor: Color(0xFF0D1B2A),
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            selectedLabelStyle: TextStyle(color: Color(0xFF0D1B2A)),
            unselectedLabelStyle: TextStyle(color: Colors.white),

            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: "Aprender",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_fill),
                label: "Juegos",
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.download),
                  label: "Descargar",
              ),
            ],
          ),
        ),
      );
  }
}
