import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'device_id_manager.dart';
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Movie Night"),
        ),
        body: const WelcomeScreen(),
      ),
    );
  }
}
