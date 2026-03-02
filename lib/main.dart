import 'package:deal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'presentation/pages/home/main_navigation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NdokotiApp());
}

class NdokotiApp extends StatelessWidget {
  const NdokotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ndokoti',
      theme: AppTheme.lightTheme,
      home: const MainNavigationPage(),
    );
  }
}
