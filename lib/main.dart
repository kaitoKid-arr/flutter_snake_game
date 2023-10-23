import 'package:flutter/material.dart';
import 'package:snake_game/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDu31Dp0Dr46h2FmvvGhqYiZzUGXxOAN1I",
      authDomain: "snake-game-550ae.firebaseapp.com",
      projectId: "snake-game-550ae",
      storageBucket: "snake-game-550ae.appspot.com",
      messagingSenderId: "532198658648",
      appId: "1:532198658648:web:544faaca4fe0c87c8db02d",
      measurementId: "G-8CCHLPZ980",
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: HomePage(),
    );
  }
}
