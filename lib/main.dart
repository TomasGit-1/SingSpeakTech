import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sing_speak_tech/home/home.dart';
import 'package:sing_speak_tech/login/login_view.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  User? user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(user));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    print("USER LOGIN $user");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: user == null ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
