import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/utils/app_categories.dart';
import 'package:kisanbazaar/screens/buyer/category_products_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = AppCategories.selectable;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Explore Categories", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryProductsScreen(categoryTitle: cat.title),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    cat.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
