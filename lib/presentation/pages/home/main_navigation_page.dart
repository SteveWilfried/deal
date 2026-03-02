import 'package:deal/core/theme/app_colors.dart';
import 'package:deal/presentation/pages/home/homepage.dart';
import 'package:deal/presentation/widgets/bottom_navbar.dart';
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
    Center(child: Text("Recherche")),
    Center(child: Text("Publier un deal")),
    Center(child: Text("Messages")),
    Center(child: Text("Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          "Ndokoti",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
