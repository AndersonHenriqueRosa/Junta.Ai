import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juntaai/firebase_options.dart';
import 'package:juntaai/screens/home/home_screen.dart';
import 'package:juntaai/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bem-Vindo ao Junta.Ai',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'), 
      ],
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          floatingLabelStyle: TextStyle(color: Colors.orange),
        ),
        
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(
        //     foregroundColor: Colors.white, backgroundColor: Colors.orange, 
        //     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), 
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12), 
        //     ),
        //   ),
        // ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange, width: 2), 
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: RouterScreen(),
    );
  }
}

class RouterScreen extends StatelessWidget {
  const RouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const WelcomeScreen();
          }
        });
  }
}
