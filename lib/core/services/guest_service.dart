import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  GuestService — Gestion du mode invité
//
//  Un invité peut :
//    ✅ Voir les annonces
//    ✅ Rechercher
//    ✅ Voir les détails
//
//  Un invité ne peut PAS :
//    ❌ Publier une annonce
//    ❌ Ajouter aux favoris
//    ❌ Envoyer un message
//    ❌ Accéder à son profil
// ═══════════════════════════════════════════════════════════

class GuestService {
  GuestService._();
  static final GuestService instance = GuestService._();

  bool _isGuest = false;
  bool get isGuest => _isGuest;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool('is_guest') ?? false;
  }

  Future<void> setGuest(bool value) async {
    _isGuest = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', value);
  }

  Future<void> signOut() async {
    _isGuest = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_guest');
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
  }

  /// Vérifie si l'action est autorisée pour un invité.
  /// Si non autorisée, affiche un dialog de connexion et retourne false.
  bool requireAuth(BuildContext context, {String? reason}) {
    if (!_isGuest) return true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.cta, size: 24),
            SizedBox(width: 10),
            Text(
              'Connexion requise',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          reason ?? 'Connectez-vous pour accéder à cette fonctionnalité.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Plus tard',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Se connecter',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return false;
  }
}
