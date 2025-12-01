import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sing_speak_tech/auth/google_signin_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setState(() => error = e.toString());
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/login/opcion1.svg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // ---------- LOGO ARRIBA ----------
                  const SizedBox(height: 100),
                  const Text(
                    "Aprende LSM",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Image.asset("assets/login/mano3d.png", height: 300),

                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user =
                            await GoogleSignInService.signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacementNamed(context, "/home");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        foregroundColor: const Color(0xFF3D3D3D),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/login/GoogleIcon.png", height: 32),
                          const SizedBox(width: 10),
                          const Text("Continuar con Google"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 150), // MARGEN FINAL
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextFieldDesign extends StatelessWidget {
  const TextFieldDesign({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A), // Fondo oscuro EXACTO
        borderRadius: BorderRadius.circular(28), // Bordes súper redondeados
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 10),
            child: Icon(
              icon, // Ícono dinámico
              size: 28,
              color: Colors.white,
            ),
          ),

          hintText: hint, // Texto dinámico
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 17),

          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 0,
          ),
        ),
      ),
    );
  }
}
