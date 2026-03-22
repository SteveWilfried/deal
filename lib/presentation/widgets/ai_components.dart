import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  NDOKOTI — Composants IA réutilisables
//
//  AiBadge           Badge "IA activée" pulsant (header)
//  AiLabel           Label "✦ IA" inline
//  AiSectionHeader   Header de section IA avec titre + voir tout
//  AiSuggestionChip  Chip suggestion contextuelle (compact / élargi)
//  AiSearchBar       Barre recherche avec micro + caméra
//  AiGenerateButton  Bouton "Générer avec l'IA"
//  AiGeneratingCard  Carte animation génération en cours
//  AiPriceBadge      Badge prix suggéré par l'IA
//  AiResultBanner    Bandeau "Résultats triés par l'IA"
//  AiTip             Encart conseil / info IA
//  AiGeneratedBanner Bandeau "contenu généré par l'IA"
//  AiInsightCard     Card conseil dashboard vendeur
// ═══════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  AiBadge
// ─────────────────────────────────────────────
class AiBadge extends StatefulWidget {
  final String label;
  const AiBadge({super.key, this.label = 'IA activée'});
  @override
  State<AiBadge> createState() => _AiBadgeState();
}

class _AiBadgeState extends State<AiBadge> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.78,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          gradient: AppColors.gradientAi,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.shadowAi,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiLabel
// ─────────────────────────────────────────────
class AiLabel extends StatelessWidget {
  final String text;
  const AiLabel({super.key, this.text = '✦  IA'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.gradientAi,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiSectionHeader
// ─────────────────────────────────────────────
class AiSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const AiSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AiLabel(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Tout voir →',
              style: TextStyle(
                color: AppColors.cta,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  AiSuggestionChip
// ─────────────────────────────────────────────
class AiSuggestionChip extends StatelessWidget {
  final String label;
  final String emoji;
  final String? tag;
  final VoidCallback? onTap;
  final bool compact;

  const AiSuggestionChip({
    super.key,
    required this.label,
    this.emoji = '',
    this.tag,
    this.onTap,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji.isNotEmpty) ...[
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Version élargie avec tag
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.shadowSm,
        ),
        child: Row(
          children: [
            if (emoji.isNotEmpty)
              Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (tag != null)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.aiBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag!,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.aiPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

// ─────────────────────────────────────────────
//  AiSearchBar
// ─────────────────────────────────────────────
class AiSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onImageSearch;
  final VoidCallback? onVoiceSearch;
  final bool isListening;
  final double waveValue;
  final String hint;

  const AiSearchBar({
    super.key,
    this.onTap,
    this.onImageSearch,
    this.onVoiceSearch,
    this.isListening = false,
    this.waveValue = 0,
    this.hint = 'Ex: "téléphone pas cher à Douala"',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hint,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _vDiv(),
          _SBarAction(
            icon: Icons.camera_alt_rounded,
            label: 'Image',
            color: AppColors.cta,
            onTap: onImageSearch,
          ),
          _vDiv(),
          _SBarAction(
            icon: isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            label: isListening ? 'Écoute…' : 'Voix',
            color: isListening ? AppColors.aiPrimary : AppColors.textSecondary,
            onTap: onVoiceSearch,
            waveValue: waveValue,
            isActive: isListening,
          ),
        ],
      ),
    );
  }
}

Widget _vDiv() => Container(width: 1, height: 30, color: AppColors.border);

class _SBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;
  final double waveValue;

  const _SBarAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isActive = false,
    this.waveValue = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (waveValue > 0)
              ...List.generate(
                2,
                (i) => Transform.scale(
                  scale: 1.0 + (i + 1) * 0.35 * waveValue,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.aiPrimary.withOpacity(
                        0.07 * (1 - waveValue),
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiGenerateButton
// ─────────────────────────────────────────────
class AiGenerateButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const AiGenerateButton({
    super.key,
    this.label = '✦  Générer l\'annonce avec l\'IA',
    this.subtitle = 'Titre, description et prix en 3 secondes',
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
                )
              : AppColors.gradientAi,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading ? [] : AppColors.shadowAi,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiGeneratingCard
// ─────────────────────────────────────────────
class AiGeneratingCard extends StatefulWidget {
  final List<String> steps;
  final int currentStep;
  const AiGeneratingCard({
    super.key,
    required this.steps,
    required this.currentStep,
  });
  @override
  State<AiGeneratingCard> createState() => _AiGeneratingCardState();
}

class _AiGeneratingCardState extends State<AiGeneratingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.aiBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.aiBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.gradientAi,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aiPrimary.withOpacity(0.3 * _glow.value),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Agent IA en cours…',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.aiPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.steps.length, (i) {
              final isDone = i < widget.currentStep;
              final isCurrent = i == widget.currentStep;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : isCurrent
                            ? AppColors.aiPrimary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? AppColors.success
                              : isCurrent
                              ? AppColors.aiPrimary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : isCurrent
                            ? Icons.more_horiz_rounded
                            : null,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.steps[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isDone
                              ? AppColors.success
                              : isCurrent
                              ? AppColors.aiPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiPriceBadge
// ─────────────────────────────────────────────
class AiPriceBadge extends StatelessWidget {
  final String price;
  final VoidCallback? onApply;
  const AiPriceBadge({super.key, required this.price, this.onApply});

  String _fmt(String p) {
    final n = int.tryParse(p);
    if (n == null) return p;
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.gradientAi,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.shadowAi,
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix suggéré par l\'IA',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_fmt(price)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (onApply != null)
            GestureDetector(
              onTap: onApply,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Appliquer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiResultBanner
// ─────────────────────────────────────────────
class AiResultBanner extends StatelessWidget {
  final int count;
  final String query;
  const AiResultBanner({super.key, required this.count, required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.aiBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.aiBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.aiPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '$count résultats ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: 'pour '),
                  TextSpan(
                    text: '"$query"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.aiPrimary,
                    ),
                  ),
                  const TextSpan(text: ' — triés par pertinence IA'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiTip
// ─────────────────────────────────────────────
class AiTip extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;
  const AiTip({
    super.key,
    required this.message,
    this.icon = Icons.auto_awesome_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.aiPrimary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiGeneratedBanner
// ─────────────────────────────────────────────
class AiGeneratedBanner extends StatelessWidget {
  final VoidCallback? onClear;
  const AiGeneratedBanner({super.key, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: AppColors.gradientAi,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Contenu généré par l\'IA Ndokoti — Modifiez si nécessaire',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'Effacer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AiInsightCard — Dashboard vendeur
// ─────────────────────────────────────────────
class AiInsightCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  const AiInsightCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.aiPrimary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'IA',
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientAi,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
