import 'package:deal/presentation/widgets/custom_button.dart';
import 'package:deal/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import '../pages/home/main_navigation_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // remplacer par auth réel
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailCtl,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty) ? 'Email requis' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _passCtl,
            hintText: 'Mot de passe',
            obscureText: true,
            validator: (v) =>
                (v == null || v.length < 6) ? '6+ caractères' : null,
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: _loading ? 'Connexion...' : 'Se connecter',
            onPressed: _loading ? null : _submit,
            text: '',
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: ouvrir page d'inscription
            },
            child: const Text("Pas de compte ? S'inscrire"),
          ),
        ],
      ),
    );
  }
}
