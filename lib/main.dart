import 'package:deal/core/theme/app_theme.dart';
import 'package:deal/presentation/pages/auth/auth_flow.dart';
import 'package:deal/presentation/pages/home/main_navigation_page.dart';
import 'package:deal/presentation/pages/splash/splash_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Barre de statut transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Portrait uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      // Démarre sur le SplashScreen — il redirige ensuite vers Onboarding ou Auth
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const AuthWelcomePage(),
        '/home': (context) => const MainNavigationPage(),
      },
    );
  }
}
