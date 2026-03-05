import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service centralisé pour tous les lancements externes :
/// WhatsApp, Appel téléphonique, SMS, Email, URL web.
///
/// Usage :
///   await LauncherService.openWhatsApp(phone: '237655000000', message: 'Bonjour...');
///   await LauncherService.call(phone: '237655000000');
///   await LauncherService.sms(phone: '237655000000');
class LauncherService {
  LauncherService._();

  // ─────────────────────────────────────────────
  //  WHATSAPP
  // ─────────────────────────────────────────────

  /// Ouvre WhatsApp avec un message pré-rempli.
  /// [phone] : numéro international SANS le +  (ex: "237655123456")
  /// [message] : texte pré-rempli (optionnel)
  static Future<void> openWhatsApp({
    required BuildContext context,
    required String phone,
    String message = '',
  }) async {
    // Nettoyage : enlever espaces, tirets, +
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    final encodedMsg = Uri.encodeComponent(message);

    // Essai 1 : schéma natif whatsapp://
    final nativeUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMsg');
    // Essai 2 : lien web fallback
    final webUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMsg');

    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'WhatsApp n\'est pas installé sur cet appareil.');
    }
  }

  // ─────────────────────────────────────────────
  //  APPEL TÉLÉPHONIQUE
  // ─────────────────────────────────────────────

  /// Lance un appel téléphonique.
  /// [phone] : numéro avec ou sans le + (ex: "+237655123456" ou "237655123456")
  static Future<void> call({
    required BuildContext context,
    required String phone,
  }) async {
    final cleanPhone = phone.startsWith('+') ? phone : '+$phone';
    final uri = Uri.parse('tel:$cleanPhone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError(context, 'Impossible de lancer l\'appel.');
    }
  }

  // ─────────────────────────────────────────────
  //  SMS
  // ─────────────────────────────────────────────

  /// Ouvre l'application SMS avec un numéro pré-rempli.
  static Future<void> sms({
    required BuildContext context,
    required String phone,
    String body = '',
  }) async {
    final cleanPhone = phone.startsWith('+') ? phone : '+$phone';
    final separator = body.isNotEmpty ? '?body=${Uri.encodeComponent(body)}' : '';
    final uri = Uri.parse('sms:$cleanPhone$separator');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError(context, 'Impossible d\'ouvrir les SMS.');
    }
  }

  // ─────────────────────────────────────────────
  //  LIEN WEB
  // ─────────────────────────────────────────────

  /// Ouvre un lien dans le navigateur externe.
  static Future<void> openUrl({
    required BuildContext context,
    required String url,
  }) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Impossible d\'ouvrir le lien.');
    }
  }

  // ─────────────────────────────────────────────
  //  MESSAGE D'ERREUR
  // ─────────────────────────────────────────────
  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPER : message WhatsApp Ndokoti pré-formaté
  // ─────────────────────────────────────────────

  /// Génère le message WhatsApp standard pour une annonce Ndokoti.
  static String buildDealMessage({
    required String dealTitle,
    required String price,
    required String dealId,
  }) {
    return 'Bonjour, je suis intéressé(e) par votre annonce '
        '"$dealTitle" à $price sur Ndokoti.\n'
        'Référence : ndokoti.cm/deal/$dealId';
  }
}
