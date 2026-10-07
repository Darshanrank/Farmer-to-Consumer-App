import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'dart:convert';
import '../../domain/entities/cart_item.dart';
import '../../data/cart_repository.dart';
import '../providers/shopping_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _addToCart() async {
    final products = ref.read(buyerProductsProvider).value ?? [];
    final matchingProducts = products.where((p) => p.id == widget.productId);
    if (matchingProducts.isEmpty) return;
    final product = matchingProducts.first;
    final user = ref.read(authUserProvider).value;

    if (user == null || product.isOutOfStock || product.stockQuantity < product.minOrderQuantity) {
      return;
    }
    if (_quantity < product.minOrderQuantity) {
      setState(() => _quantity = product.minOrderQuantity);
    }
    if (_quantity > product.stockQuantity) {
      setState(() => _quantity = product.stockQuantity);
    }

    setState(() => _isAdding = true);

    final cartItem = CartItem(
      id: product.id,
      productId: product.id,
      sellerId: product.sellerId,
      name: product.name,
      price: product.price,
      unit: product.unit,
      quantity: _quantity,
      imageBase64: product.images.isNotEmpty ? base64Encode(product.images.first.data) : null,
      addedAt: DateTime.now(),
    );

    final result = await ref.read(cartRepositoryProvider).addToCart(
      userId: user.uid,
      item: cartItem,
    );

    if (mounted) {
      setState(() => _isAdding = false);
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart!'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${result.exceptionOrNull?.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(buyerProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (products) {
          final matchingProducts = products.where((p) => p.id == widget.productId);
          if (matchingProducts.isEmpty) {
            return const Center(child: Text('Product is no longer available.'));
          }
          final product = matchingProducts.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (product.images.isNotEmpty)
                        Image.memory(
                          product.images.first.data,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 64, color: Colors.grey),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${product.price} / ${product.unit}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Category: ${product.category}'),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Quantity selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _decrement,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: product.isOutOfStock || _quantity >= product.stockQuantity
                                  ? null
                                  : _increment,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // Add to Cart button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAdding ||
                                  product.isOutOfStock ||
                                  product.stockQuantity < product.minOrderQuantity
                              ? null
                              : _addToCart,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isAdding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  product.isOutOfStock ||
                                          product.stockQuantity < product.minOrderQuantity
                                      ? 'Out of stock'
                                      : 'Add to Cart - ₹${(product.price * _quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
