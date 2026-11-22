import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/login_page.dart'; // PARA VER COMO QUEDA

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Objetos perdidos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          //estos colores son temporales(ninguno me gusta)
          seedColor: const Color(0xFF0F4C5C),
          secondary: const Color(0xFFFFB38A),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
