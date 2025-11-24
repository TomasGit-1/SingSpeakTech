import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Iniciar flujo de Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      // 2. Obtener tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Construir credencial de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }
}
