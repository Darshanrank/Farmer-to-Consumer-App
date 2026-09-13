import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/services/product_service.dart';
import 'package:kisanbazaar/services/cart_service.dart';
import 'package:kisanbazaar/models/product_model.dart';
import 'package:kisanbazaar/widgets/modern_product_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryTitle;

  const CategoryProductsScreen({super.key, required this.categoryTitle});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();

  bool _inStockOnly = false;
  String _sortOption = 'relevance';

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('In Stock Only'),
              selected: _inStockOnly,
              onSelected: (val) => setState(() => _inStockOnly = val),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Price: Low to High'),
              selected: _sortOption == 'price_asc',
              onSelected: (val) => setState(() => _sortOption = val ? 'price_asc' : 'relevance'),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Price: High to Low'),
              selected: _sortOption == 'price_desc',
              onSelected: (val) => setState(() => _sortOption = val ? 'price_desc' : 'relevance'),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  void addToCart(ProductModel product) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Fluttertoast.showToast(msg: "Please login to add to cart");
      return;
    }
    await _cartService.addToCart(buyerId: userId, productData: product.toJson());
    Fluttertoast.showToast(msg: "${product.name} added to cart!", backgroundColor: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.streamProductsByCategory(widget.categoryTitle),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading products", style: TextStyle(color: AppColors.error)));
                }

                var products = snapshot.data ?? [];

                if (_inStockOnly) {
                  products = products.where((p) => p.isAvailable).toList();
                }

                if (_sortOption == 'price_asc') {
                  products.sort((a, b) => a.price.compareTo(b.price));
                } else if (_sortOption == 'price_desc') {
                  products.sort((a, b) => b.price.compareTo(a.price));
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text("No products found.", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ModernProductCard(
                      data: products[index].toJson(),
                      onAdd: () => addToCart(products[index]),
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
