import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: AnimatedSplashScreen(
          splash: Image.asset('assets/images/logo.png'),
          splashIconSize: 150,
          duration: 3000,
          backgroundColor: const Color.fromARGB(255, 40, 38, 38),
          splashTransition: SplashTransition.fadeTransition,
          nextScreen: const WelcomeScreen()),
    );
  }
}
