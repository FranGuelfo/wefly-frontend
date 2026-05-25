import 'package:flutter/material.dart';

class WeFlyTheme {
  static const Color orangePrimary = Color(0xFFF15A24);
  static const Color redSecondary = Color(0xFFE63946);
  
  static const Gradient mainGradient = LinearGradient(
    colors: [orangePrimary, redSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: orangePrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orangePrimary,
        secondary: redSecondary,
      ),
      fontFamily: 'Poppins', // Asegúrate de tenerla en pubspec.yaml o usa la por defecto
      useMaterial3: true,
    );
  }
}