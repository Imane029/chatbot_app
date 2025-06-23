import 'package:flutter/material.dart';
import 'package:chatbot_app/login_screen.dart'; // Importez votre page de connexion

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application de Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // useMaterial3: true, // Vous pouvez décommenter si vous utilisez Flutter 3.x et voulez Material 3
      ),
      home: const LoginScreen(), // Définissez LoginScreen comme la page d'accueil
    );
  }
}