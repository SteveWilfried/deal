import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════
//  NdokotiButton — Bouton principal de l'app
//  Variants : primary | secondary | outline | ghost | ai | danger
// ═══════════════════════════════════════════════

enum BtnVariant { primary, secondary, outline, ghost, ai, danger }

class NdokotiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final IconData? icon;
  final double borderRadius;

  const NdokotiButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = BtnVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 52,
    this.icon,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || onTap == null) ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: fullWidth ? double.infinity : null,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: _gradient,
            color: _gradient == null ? _solidColor : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: _border,
            boxShadow: _shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: _textColor,
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (icon != null) ...[
                Icon(icon, color: _textColor, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient? get _gradient {
    switch (variant) {
      case BtnVariant.primary:   return AppColors.gradientCta;
      case BtnVariant.ai:        return AppColors.gradientAi;
      default: return null;
    }
  }

  Color? get _solidColor {
    switch (variant) {
      case BtnVariant.secondary: return AppColors.primary;
      case BtnVariant.outline:   return Colors.transparent;
      case BtnVariant.ghost:     return AppColors.surfaceAlt;
      case BtnVariant.danger:    return AppColors.error;
      default: return null;
    }
  }

  Color get _textColor {
    switch (variant) {
      case BtnVariant.outline: return AppColors.primary;
      case BtnVariant.ghost:   return AppColors.textPrimary;
      default: return Colors.white;
    }
  }

  Border? get _border {
    if (variant == BtnVariant.outline) {
      return Border.all(color: AppColors.border, width: 1.5);
    }
    return null;
  }

  List<BoxShadow> get _shadow {
    switch (variant) {
      case BtnVariant.primary:   return AppColors.shadowCta;
      case BtnVariant.ai:        return AppColors.shadowAi;
      case BtnVariant.secondary: return AppColors.shadowMd;
      default: return [];
    }
  }
}

// Alias rétrocompatible pour l'ancien CustomButton
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 14,
    this.isLoading = false,
    this.enabled = true,
    String? label,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.cta;
    final fg = foregroundColor ?? Colors.white;
    return GestureDetector(
      onTap: (enabled && !isLoading) ? onPressed : null,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: AppColors.shadowSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg))
            else ...[
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(text, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}
