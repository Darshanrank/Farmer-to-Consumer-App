// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/screens/seller/edit_product_screen.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _deleteProduct(String productId, String productName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text('Are you sure you want to delete "$productName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('products').doc(productId).delete();

        final cartSnapshot = await FirebaseFirestore.instance.collection('cart').where('productId', isEqualTo: productId).get();

        if (cartSnapshot.docs.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          for (var doc in cartSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully'), backgroundColor: AppColors.success));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _editProduct(String productId, Map<String, dynamic> productData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          productId: productId,
          productData: productData,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Premium Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Products', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('products').where('sellerId', isEqualTo: currentUserId).snapshots(),
                            builder: (context, snap) {
                              int count = snap.hasData ? snap.data!.docs.length : 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                                child: Text('$count product${count != 1 ? 's' : ''} listed', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Products List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').where('sellerId', isEqualTo: currentUserId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: 24),
                        const Text('No products yet', style: TextStyle(fontSize: 20, color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        const Text('Add your first product to get started', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final productData = doc.data() as Map<String, dynamic>;
                    return _buildProductCard(productId: doc.id, productData: productData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({required String productId, required Map<String, dynamic> productData}) {
    final String name = productData['name'] ?? 'Unknown';
    final double price = (productData['price'] ?? 0).toDouble();
    final int quantity = (productData['quantity'] ?? 0).toInt();
    final String category = productData['category'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _editProduct(productId, productData),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: KisanImage(
                    imageSource: productData['imageUrl'] ?? productData['image'] ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(category, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text('$quantity Stock', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Column(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.edit_rounded, color: Colors.blue, size: 18)
                    ),
                    onPressed: () => _editProduct(productId, productData),
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(bottom: 8),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18)
                    ),
                    onPressed: () => _deleteProduct(productId, name),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
