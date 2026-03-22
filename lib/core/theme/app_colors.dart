import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
//  NDOKOTI — Palette complète
//  Marque | Surfaces | Textes | Statuts | IA | Gradients
// ═══════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── Couleurs de marque ──────────────────────────────────
  static const Color primary = Color(0xFF0D1B2A); // Navy profond
  static const Color cta = Color(0xFFF57C00); // Orange chaleureux
  static const Color accent = Color(0xFFD4AF37); // Or Ndokoti

  // ── Surfaces ────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F2F5);
  static const Color border = Color(0xFFE5E7EB);

  // ── Textes ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  // ── Statuts ─────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFB71C1C);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoBg = Color(0xFFE3F2FD);

  // ── Badges fonctionnels ─────────────────────────────────
  static const Color flash = Color(0xFFE65100);
  static const Color flashBg = Color(0xFFFBE9E7);
  static const Color verified = Color(0xFF2E7D32);
  static const Color verifiedBg = Color(0xFFE8F5E9);
  static const Color boosted = Color(0xFFD4AF37);
  static const Color boostedBg = Color(0xFFFFFDE7);
  static const Color reseller = Color(0xFF6A1B9A);
  static const Color resellerBg = Color(0xFFF3E5F5);

  // ── IA Ndokoti ──────────────────────────────────────────
  static const Color aiPrimary = Color(0xFF6A1B9A); // Violet IA
  static const Color aiSecondary = Color(0xFF1565C0); // Bleu IA
  static const Color aiBg = Color(0xFFF5F0FF); // Fond doux IA
  static const Color aiBorder = Color(0xFFD1B8F0); // Bordure IA
  static const Color aiText = Color(0xFF4A0E7A);

  // ── Couleurs par catégorie ───────────────────────────────
  static const Color catElectronique = Color(0xFF1565C0);
  static const Color catImmobilier = Color(0xFF2E7D32);
  static const Color catAuto = Color(0xFFE65100);
  static const Color catServices = Color(0xFF6A1B9A);
  static const Color catMode = Color(0xFFC62828);
  static const Color catMaison = Color(0xFF00695C);
  static const Color catLoisirs = Color(0xFFF57C00);
  static const Color catAnimaux = Color(0xFF4E342E);
  static const Color catEmploi = Color(0xFF00838F);
  static const Color catRencontre = Color(0xFFAD1457);
  static const Color catAutre = Color(0xFF546E7A);

  // ── Gradients ───────────────────────────────────────────
  static const LinearGradient gradientAi = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientFlash = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientBrand = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1A3550)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientCta = LinearGradient(
    colors: [Color(0xFFF57C00), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientVerified = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
  );

  // ── Ombres ──────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
  static List<BoxShadow> get shadowAi => [
    BoxShadow(
      color: aiPrimary.withOpacity(0.28),
      blurRadius: 16,
      offset: const Offset(0, 5),
    ),
  ];
  static List<BoxShadow> get shadowCta => [
    BoxShadow(
      color: cta.withOpacity(0.35),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];
  static List<BoxShadow> get shadowFlash => [
    BoxShadow(
      color: flash.withOpacity(0.30),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
}
