import 'package:flutter/material.dart';
import '../../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: const Padding(padding: EdgeInsets.all(16), child: LoginForm()),
    );
  }
}
