import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/deal_card.dart';
import '../../widgets/category_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// 🔹 SEARCH BAR PREMIUM
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Que recherchez vous",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Icon(Icons.photo_camera, color: AppColors.cta),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// 🔹 CATEGORIES
              const Text(
                "Populaires",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CategoryItem(
                      icon: Icons.phone_iphone,
                      label: "Électronique",
                    ),
                    CategoryItem(icon: Icons.home, label: "Immobilier"),
                    CategoryItem(icon: Icons.directions_car, label: "Auto"),
                    CategoryItem(
                      icon: Icons.design_services,
                      label: "Services",
                    ),
                    CategoryItem(icon: Icons.shopping_bag, label: "Mode"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// 🔹 DEALS SECTION
              const Text(
                "Deals populaires 🔥",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 DEAL LIST
              const DealCard(
                title: "iPhone 13 Pro Max 256GB",
                price: "450 000 FCFA",
                location: "Bonamoussadi - Douala",
                image: "https://picsum.photos/400/300",
              ),

              const DealCard(
                title: "Appartement 2 chambres moderne",
                price: "150 000 FCFA / mois",
                location: "Makepe - Douala",
                image: "https://picsum.photos/401/300",
              ),

              const DealCard(
                title: "Toyota Corolla 2018",
                price: "5 500 000 FCFA",
                location: "Akwa - Douala",
                image: "https://picsum.photos/402/300",
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
