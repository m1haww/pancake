import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(PancakeApp());
}

class PancakeApp extends StatelessWidget {
  PancakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pancake Recipes',
      theme: AppTheme.theme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}