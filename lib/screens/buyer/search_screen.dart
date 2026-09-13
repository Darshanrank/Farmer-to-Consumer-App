import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/services/product_service.dart';
import 'package:kisanbazaar/services/cart_service.dart';
import 'package:kisanbazaar/models/product_model.dart';
import 'package:kisanbazaar/widgets/modern_product_card.dart';
import 'package:kisanbazaar/widgets/modern_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  bool _inStockOnly = false;
  String _sortOption = 'relevance';

  final List<String> _trendingSearches = [
    "Premium Wheat Seeds", "Organic Fertilizer", "Drip Irrigation", 
    "Tractor Parts", "Pesticides", "Gardening Tools", "Hybrid Seeds"
  ];

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCustomChip(
              label: 'In Stock Only',
              isSelected: _inStockOnly,
              onTap: () => setState(() => _inStockOnly = !_inStockOnly),
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(width: 8),
            _buildCustomChip(
              label: 'Price: Low to High',
              isSelected: _sortOption == 'price_asc',
              onTap: () => setState(() => _sortOption = _sortOption == 'price_asc' ? 'relevance' : 'price_asc'),
              icon: Icons.arrow_upward_rounded,
            ),
            const SizedBox(width: 8),
            _buildCustomChip(
              label: 'Price: High to Low',
              isSelected: _sortOption == 'price_desc',
              onTap: () => setState(() => _sortOption = _sortOption == 'price_desc' ? 'relevance' : 'price_desc'),
              icon: Icons.arrow_downward_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomChip({required String label, required bool isSelected, required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))] : []
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: ModernSearchBar(
          controller: _searchController,
          autofocus: true,
          hint: "Search for anything...",
          onChanged: (val) => setState(() => _query = val.trim()),
        ),
        titleSpacing: 0,
        actions: [const SizedBox(width: 16)],
      ),
      body: _query.isEmpty
          ? _buildTrendingState()
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: StreamBuilder<List<ProductModel>>(
                    stream: _productService.streamSearchProducts(_query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error searching products", style: TextStyle(color: AppColors.error)));
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
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: Icon(Icons.search_off_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                              ),
                              const SizedBox(height: 24),
                              Text("No results for '$_query'", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              const Text("Try checking your spelling or use more general terms", style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center,),
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

  Widget _buildTrendingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Trending Searches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _trendingSearches.map((term) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = term;
                  setState(() => _query = term);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))]
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(term, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 40),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24)
            ),
            child: Column(
              children: [
                Icon(Icons.search_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text("What are you looking for?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const SizedBox(height: 8),
                const Text("Search for premium seeds, fertilizers, tools, or organic inputs", style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
              ],
            ),
          )
        ],
      ),
    );
  }
}
