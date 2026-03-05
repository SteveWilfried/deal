import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────
class DealDraft {
  // Étape 1
  String? categoryId;
  String? categoryLabel;

  // Étape 2
  List<File> photos = [];

  // Étape 3
  String title = '';
  String description = '';

  // Étape 4
  String price = '';
  String city = '';
  String condition = 'Neuf'; // Neuf | Occasion | Reconditionné

  // Étape 5
  bool availableForResellers = false;
  String? wholesalePrice;
}

// ─────────────────────────────────────────────
//  CATEGORIES DATA
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> kCategories = [
  {'id': 'electronics', 'label': 'Électronique', 'icon': Icons.phone_iphone},
  {'id': 'immobilier',  'label': 'Immobilier',   'icon': Icons.home},
  {'id': 'auto',        'label': 'Auto / Moto',  'icon': Icons.directions_car},
  {'id': 'services',    'label': 'Services',     'icon': Icons.design_services},
  {'id': 'mode',        'label': 'Mode',         'icon': Icons.shopping_bag},
  {'id': 'maison',      'label': 'Maison',       'icon': Icons.chair},
  {'id': 'emploi',      'label': 'Emploi',       'icon': Icons.work_outline},
  {'id': 'loisirs',     'label': 'Loisirs',      'icon': Icons.sports_esports},
  {'id': 'animaux',     'label': 'Animaux',      'icon': Icons.pets},
  {'id': 'autre',       'label': 'Autre',        'icon': Icons.category_outlined},
];

const List<String> kCities = [
  'Douala', 'Yaoundé', 'Bafoussam', 'Garoua', 'Bamenda',
  'Maroua', 'Ngaoundéré', 'Bertoua', 'Ebolowa', 'Kribi',
  'Libreville', 'Port-Gentil',
];

// ─────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────
class PublishDealPage extends StatefulWidget {
  const PublishDealPage({super.key});

  @override
  State<PublishDealPage> createState() => _PublishDealPageState();
}

class _PublishDealPageState extends State<PublishDealPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final int _totalSteps = 5;
  final DealDraft _draft = DealDraft();

  late final AnimationController _progressController;
  late Animation<double> _progressAnim;

  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1 / _totalSteps)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _animateProgress(int nextStep) {
    final target = (nextStep + 1) / _totalSteps;
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _progressController
      ..reset()
      ..forward();
  }

  void _goNext() {
    // Validation par étape
    if (_currentStep == 0 && _draft.categoryId == null) {
      _showSnack('Choisissez une catégorie pour continuer.');
      return;
    }
    if (_currentStep == 1 && _draft.photos.isEmpty) {
      _showSnack('Ajoutez au moins une photo.');
      return;
    }
    if (_currentStep == 2) {
      if (!_step3Key.currentState!.validate()) return;
    }
    if (_currentStep == 3) {
      if (!_step4Key.currentState!.validate()) return;
    }

    if (_currentStep < _totalSteps - 1) {
      _animateProgress(_currentStep + 1);
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _animateProgress(_currentStep - 1);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    // TODO: Envoyer _draft à l'API FastAPI
    showDialog(
      context: context,
      builder: (_) => _SuccessDialog(draft: _draft),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.cta,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Step titles ──
  static const List<String> _stepTitles = [
    'Catégorie',
    'Photos',
    'Titre & Description',
    'Prix & Localisation',
    'Options',
  ];

  static const List<String> _stepSubtitles = [
    'Dans quelle catégorie rentre votre deal ?',
    'Ajoutez jusqu\'à 6 photos (la 1ère = couverture)',
    'Décrivez votre deal clairement',
    'Fixez votre prix et votre ville',
    'Paramètres supplémentaires',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── HEADER ────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepTitles[_currentStep],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _stepSubtitles[_currentStep],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cta.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1} / $_totalSteps',
              style: const TextStyle(
                color: AppColors.cta,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ──────────────────────── PROGRESS ────────────────────────
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (_, __) => LinearProgressIndicator(
        value: _progressAnim.value,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cta),
        minHeight: 3,
      ),
    );
  }

  // ──────────────────────── STEPS ────────────────────────
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _Step1Category(draft: _draft, onChanged: () => setState(() {}));
      case 1: return _Step2Photos(draft: _draft, onChanged: () => setState(() {}));
      case 2: return _Step3Description(formKey: _step3Key, draft: _draft);
      case 3: return _Step4PriceLocation(formKey: _step4Key, draft: _draft, onChanged: () => setState(() {}));
      case 4: return _Step5Options(formKey: _step5Key, draft: _draft, onChanged: () => setState(() {}));
      default: return const SizedBox();
    }
  }

  // ──────────────────────── BOTTOM BAR ────────────────────────
  Widget _buildBottomBar() {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _goNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLast ? AppColors.accent : AppColors.cta,
            foregroundColor: isLast ? AppColors.primary : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'Publier le deal' : 'Continuer',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(
                isLast ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ÉTAPE 1 — CATÉGORIE
// ═══════════════════════════════════════════════
class _Step1Category extends StatelessWidget {
  final DealDraft draft;
  final VoidCallback onChanged;

  const _Step1Category({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: kCategories.length,
            itemBuilder: (_, i) {
              final cat = kCategories[i];
              final selected = draft.categoryId == cat['id'];
              return GestureDetector(
                onTap: () {
                  draft.categoryId = cat['id'] as String;
                  draft.categoryLabel = cat['label'] as String;
                  onChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.cta.withOpacity(0.12) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.cta : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? AppColors.cta.withOpacity(0.15)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: selected ? AppColors.cta : AppColors.textSecondary,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.cta : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ÉTAPE 2 — PHOTOS
// ═══════════════════════════════════════════════
class _Step2Photos extends StatefulWidget {
  final DealDraft draft;
  final VoidCallback onChanged;

  const _Step2Photos({required this.draft, required this.onChanged});

  @override
  State<_Step2Photos> createState() => _Step2PhotosState();
}

class _Step2PhotosState extends State<_Step2Photos> {
  final _picker = ImagePicker();

  Future<void> _pickPhoto(ImageSource source) async {
    if (widget.draft.photos.length >= 6) {
      _showSnack('Maximum 6 photos atteint.');
      return;
    }
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (file != null) {
        setState(() {
          widget.draft.photos.add(File(file.path));
        });
        widget.onChanged();
      }
    } catch (e) {
      _showSnack('Impossible d\'accéder aux photos. Vérifiez les permissions.');
    }
  }

  void _removePhoto(int index) {
    setState(() => widget.draft.photos.removeAt(index));
    widget.onChanged();
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Ajouter une photo',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 16),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cta.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: AppColors.cta),
              ),
              title: const Text('Galerie photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Choisir depuis vos photos'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
              ),
              title: const Text('Appareil photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Prendre une nouvelle photo'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conseil
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Les annonces avec 3+ photos reçoivent 70% plus de contacts.',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Grille photos
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 6,
            itemBuilder: (_, i) {
              final hasPhoto = i < widget.draft.photos.length;
              final isFirst = i == 0;

              return GestureDetector(
                onTap: () => hasPhoto ? null : _showSourceSheet(),
                child: Container(
                  decoration: BoxDecoration(
                    color: hasPhoto ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasPhoto ? Colors.transparent : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                    ],
                  ),
                  child: hasPhoto
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                widget.draft.photos[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            // Badge couverture
                            if (isFirst)
                              Positioned(
                                bottom: 4, left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.cta,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Couverture',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            // Bouton supprimer
                            Positioned(
                              top: 4, right: 4,
                              child: GestureDetector(
                                onTap: () => _removePhoto(i),
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              i == 0 ? Icons.add_photo_alternate_outlined : Icons.add,
                              color: i == 0 ? AppColors.cta : AppColors.textSecondary,
                              size: i == 0 ? 32 : 24,
                            ),
                            if (i == 0) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'Ajouter',
                                style: TextStyle(fontSize: 11, color: AppColors.cta, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          const Text(
            'Formats acceptés : JPG, PNG · Max 5 Mo par photo',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ÉTAPE 3 — TITRE & DESCRIPTION
// ═══════════════════════════════════════════════
class _Step3Description extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final DealDraft draft;

  const _Step3Description({required this.formKey, required this.draft});

  @override
  State<_Step3Description> createState() => _Step3DescriptionState();
}

class _Step3DescriptionState extends State<_Step3Description> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _descCtl;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.draft.title);
    _descCtl = TextEditingController(text: widget.draft.description);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(icon: Icons.title, text: 'Titre de l\'annonce'),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleCtl,
              hintText: 'Ex: Samsung Galaxy A14 128Go — État neuf',
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => widget.draft.title = v,
              validator: (v) {
                if (v == null || v.trim().length < 5) return 'Titre trop court (5 caractères min)';
                if (v.trim().length > 100) return 'Titre trop long (100 caractères max)';
                return null;
              },
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_titleCtl.text.length}/100',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 24),
            const _SectionLabel(icon: Icons.description_outlined, text: 'Description'),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _descCtl,
              hintText: 'Décrivez l\'état, les caractéristiques, ce qui est inclus...',
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => widget.draft.description = v,
              validator: (v) {
                if (v == null || v.trim().length < 20) return 'Description trop courte (20 caractères min)';
                return null;
              },
            ),

            const SizedBox(height: 20),
            // Conseils rédaction
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('💡 Conseils pour une bonne annonce',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  SizedBox(height: 8),
                  _Tip(text: 'Précisez l\'état exact du produit'),
                  _Tip(text: 'Mentionnez ce qui est inclus (facture, accessoires...)'),
                  _Tip(text: 'Indiquez la raison de la vente si c\'est d\'occasion'),
                  _Tip(text: 'Évitez le tout-majuscules et les fautes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ÉTAPE 4 — PRIX & LOCALISATION
// ═══════════════════════════════════════════════
class _Step4PriceLocation extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final DealDraft draft;
  final VoidCallback onChanged;

  const _Step4PriceLocation({
    required this.formKey,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_Step4PriceLocation> createState() => _Step4PriceLocationState();
}

class _Step4PriceLocationState extends State<_Step4PriceLocation> {
  late final TextEditingController _priceCtl;

  static const List<String> _conditions = ['Neuf', 'Occasion', 'Reconditionné'];

  @override
  void initState() {
    super.initState();
    _priceCtl = TextEditingController(text: widget.draft.price);
  }

  @override
  void dispose() {
    _priceCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PRIX ──
            const _SectionLabel(icon: Icons.payments_outlined, text: 'Prix'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceCtl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) => widget.draft.price = v,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Entrez un prix';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Prix invalide';
                return null;
              },
              decoration: InputDecoration(
                hintText: '0',
                suffixText: 'FCFA',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cta, width: 2),
                ),
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Laissez 0 pour afficher "Prix à débattre"',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            // ── ÉTAT DU PRODUIT ──
            const _SectionLabel(icon: Icons.star_outline, text: 'État du produit'),
            const SizedBox(height: 10),
            Row(
              children: _conditions.map((cond) {
                final selected = widget.draft.condition == cond;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.draft.condition = cond;
                      widget.onChanged();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cond,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── VILLE ──
            const _SectionLabel(icon: Icons.location_on_outlined, text: 'Ville'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: widget.draft.city.isEmpty ? null : widget.draft.city,
              hint: const Text('Sélectionnez votre ville'),
              validator: (v) => v == null ? 'Sélectionnez une ville' : null,
              onChanged: (v) {
                widget.draft.city = v ?? '';
                widget.onChanged();
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cta, width: 2),
                ),
              ),
              items: kCities.map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ÉTAPE 5 — OPTIONS (Programme Revendeur)
// ═══════════════════════════════════════════════
class _Step5Options extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final DealDraft draft;
  final VoidCallback onChanged;

  const _Step5Options({
    required this.formKey,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_Step5Options> createState() => _Step5OptionsState();
}

class _Step5OptionsState extends State<_Step5Options> {
  late final TextEditingController _wholesaleCtl;

  @override
  void initState() {
    super.initState();
    _wholesaleCtl = TextEditingController(text: widget.draft.wholesalePrice ?? '');
  }

  @override
  void dispose() {
    _wholesaleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Récapitulatif ──
            _buildSummaryCard(),

            const SizedBox(height: 28),

            // ── Programme Revendeur ──
            const _SectionLabel(icon: Icons.people_outline, text: 'Programme Revendeur'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.draft.availableForResellers
                      ? AppColors.accent
                      : const Color(0xFFE5E7EB),
                  width: widget.draft.availableForResellers ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: widget.draft.availableForResellers,
                    onChanged: (v) {
                      widget.draft.availableForResellers = v;
                      widget.onChanged();
                    },
                    activeColor: AppColors.accent,
                    title: const Text(
                      'Permettre la revente',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Les revendeurs pourront lister ce produit avec leur propre marge.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                  if (widget.draft.availableForResellers) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prix de gros (pour les revendeurs)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _wholesaleCtl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (v) => widget.draft.wholesalePrice = v,
                            validator: (v) {
                              if (!widget.draft.availableForResellers) return null;
                              if (v == null || v.isEmpty) return 'Entrez le prix de gros';
                              final gros = int.tryParse(v) ?? 0;
                              final public = int.tryParse(widget.draft.price) ?? 0;
                              if (public > 0 && gros >= public) {
                                return 'Le prix de gros doit être inférieur au prix public';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: 'FCFA',
                              suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              helperText: 'Les revendeurs ajouteront leur marge par-dessus',
                              helperStyle: const TextStyle(fontSize: 11),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── CGU ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
                      children: [
                        TextSpan(text: 'En publiant, vous acceptez les '),
                        TextSpan(
                          text: 'Conditions d\'utilisation',
                          style: TextStyle(color: AppColors.cta, decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: ' de Ndokoti. Toute annonce frauduleuse entraîne la suspension du compte.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif de votre deal',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.category_outlined,
            label: 'Catégorie',
            value: widget.draft.categoryLabel ?? '—',
          ),
          _SummaryRow(
            icon: Icons.title,
            label: 'Titre',
            value: widget.draft.title.isEmpty ? '—' : widget.draft.title,
          ),
          _SummaryRow(
            icon: Icons.payments_outlined,
            label: 'Prix',
            value: widget.draft.price.isEmpty
                ? '—'
                : widget.draft.price == '0'
                    ? 'Prix à débattre'
                    : '${widget.draft.price} FCFA',
          ),
          _SummaryRow(
            icon: Icons.location_on_outlined,
            label: 'Ville',
            value: widget.draft.city.isEmpty ? '—' : widget.draft.city,
          ),
          _SummaryRow(
            icon: Icons.star_outline,
            label: 'État',
            value: widget.draft.condition,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  DIALOG SUCCÈS
// ═══════════════════════════════════════════════
class _SuccessDialog extends StatelessWidget {
  final DealDraft draft;
  const _SuccessDialog({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.cta.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.cta, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Deal publié ! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '"${draft.title.isEmpty ? 'Votre annonce' : draft.title}" est maintenant en ligne sur Ndokoti.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context)
                    ..pop() // ferme dialog
                    ..pop(); // retour home
                },
                child: const Text('Voir mon annonce', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              child: const Text('Retour à l\'accueil', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  WIDGETS UTILITAIRES PARTAGÉS
// ═══════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.cta),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.cta, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.primary, height: 1.4))),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white54),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(fontSize: 12, color: Colors.white54)),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
