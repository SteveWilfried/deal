import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/services/api_service.dart';
import 'core/services/guest_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/auth_flow.dart';
import 'presentation/pages/home/main_navigation_page.dart';
import 'presentation/pages/splash/splash_onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await _initServices();

  runApp(const NdokotiApp());
}

Future<void> _initServices() async {
  debugPrint('Ndokoti v1.0 — backend: ${AppConfig.useRealBackend ? "API" : "Demo"}');

  if (AppConfig.useRealBackend) {
    await _restoreSession();
  }
}

Future<void> _restoreSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      ApiService.instance.setToken(token);
      final valid = await AuthService.instance.ensureValidToken();
      if (!valid) {
        await prefs.remove('access_token');
        await prefs.remove('user_id');
        ApiService.instance.clearToken();
      } else {
        debugPrint('Session restauree');
      }
    }
  } catch (e) {
    debugPrint('Erreur restauration session: $e');
  }
}

class NdokotiApp extends StatelessWidget {
  const NdokotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ndokoti',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const AuthWelcomePage(),
        '/home':    (context) => const MainNavigationPage(),
      },
    );
  }
}
