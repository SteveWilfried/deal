import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════
//  DealCard — Card deal standard (grille 2 col)
// ═══════════════════════════════════════════════
class DealCard extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String image;
  final VoidCallback onTap;
  final bool isFlash;
  final bool isVerified;
  final bool isBoosted;
  final String? discountLabel; // ex: "-25%"

  const DealCard({
    super.key,
    required this.title,
    required this.price,
    required this.location,
    required this.image,
    required this.onTap,
    this.isFlash = false,
    this.isVerified = false,
    this.isBoosted = false,
    this.discountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceAlt,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textHint, size: 32),
                      ),
                    ),
                    // Badges gauche (flash + vérifié)
                    Positioned(
                      top: 7, left: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isFlash) _SmallBadge(
                            icon: Icons.bolt_rounded,
                            color: AppColors.flash,
                          ),
                          if (isVerified) ...[
                            const SizedBox(height: 3),
                            _SmallBadge(
                              icon: Icons.verified_rounded,
                              color: AppColors.verified,
                            ),
                          ],
                          if (isBoosted) ...[
                            const SizedBox(height: 3),
                            _SmallBadge(
                              icon: Icons.rocket_launch_rounded,
                              color: AppColors.boosted,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Badge remise (droite)
                    if (discountLabel != null)
                      Positioned(
                        top: 7, right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            discountLabel!,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Infos ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.cta,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 10, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge icône compact ──────────────────────
class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SmallBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 22, height: 22,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
    child: Icon(icon, color: Colors.white, size: 13),
  );
}

// ═══════════════════════════════════════════════
//  FlashDealCard — Card horizontale flash deals
// ═══════════════════════════════════════════════
class FlashDealCard extends StatelessWidget {
  final String title;
  final String price;
  final String? oldPrice;
  final String image;
  final VoidCallback onTap;

  const FlashDealCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.onTap,
    this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Image.network(
                      image, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.surfaceAlt),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientFlash,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.white, size: 10),
                            Text('FLASH', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.cta)),
                  if (oldPrice != null)
                    Text(oldPrice!, style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
