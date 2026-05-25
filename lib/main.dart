import 'package:flutter/material.dart';
import 'theme/wefly_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WeFly',
      theme: WeFlyTheme.lightTheme, // Usamos nuestro nuevo tema
      home: const MainNavigationScreen(), // Iniciamos con el menú
      // Añadimos las rutas si vas a usar Navigator.pushNamed
      routes: {
        '/login': (context) => const Scaffold(body: Center(child: Text("Pantalla de Login"))),
      },
    );
  }
}