import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login'); 
            },
          )
        ],
      ),
      body: Center(
        child: user == null
            ? const Text("Usuario no autenticado") 
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bienvenido, ${user.displayName}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.photoURL ?? ""),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.email ?? "Sin correo",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
