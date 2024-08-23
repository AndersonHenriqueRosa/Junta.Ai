import 'package:flutter/material.dart';
import 'package:juntaai/screens/welcome_screen.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bem-Vindo ao Junta.Ai',
      home: const WelcomeScreen(),
    );
  }
}