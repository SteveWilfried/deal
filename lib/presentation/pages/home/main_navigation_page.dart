import 'package:deal/core/theme/app_colors.dart';
import 'package:deal/presentation/pages/home/homepage.dart';
import 'package:deal/presentation/pages/publish/publish_deal_page.dart';
import 'package:deal/presentation/widgets/bottom_navbar.dart';
import 'package:deal/presentation/pages/profil/profile_page.dart';
import 'package:deal/presentation/pages/favorite/favorites_page.dart';
import 'package:deal/presentation/pages/search/search_page.dart';
import 'package:flutter/material.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    SizedBox(), // Placeholder — le bouton "Publier" ouvre une modale
    FavoritesPage(),
    ProfilePage(),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      // Bouton central "Publier" → navigation vers le formulaire
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PublishDealPage()),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'N',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.cta,
                ),
              ),
              TextSpan(
                text: 'dokoti',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: AppColors.primary,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
