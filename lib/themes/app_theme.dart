import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
      ),
      colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Colors.red,
          onSurface: const Color.fromARGB(255, 185, 17, 5),
          brightness: Brightness.light),
      textTheme: ThemeData.light().textTheme.copyWith(
            displayLarge:
                const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            displayMedium:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            displaySmall:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            headlineLarge:
                const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            headlineMedium:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            headlineSmall:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            bodyLarge: const TextStyle(fontSize: 16),
            bodyMedium: const TextStyle(fontSize: 14),
            bodySmall: const TextStyle(
              fontSize: 12,
            ),
          ),
      useMaterial3: true,
      fontFamily: 'Montserrat',
    );
  }
}
