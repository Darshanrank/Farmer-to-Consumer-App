import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({super.key, required this.productData});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  double get _totalPrice {
    double price = widget.productData['price'] != null 
        ? double.tryParse(widget.productData['price'].toString()) ?? 0.0 
        : 0.0;
    return price * _quantity;
  }

  void _addToCart({bool goToCart = false}) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Fluttertoast.showToast(msg: "Please login to add to cart");
      return;
    }
    
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot existing = await firestore
        .collection('cart')
        .where('buyerId', isEqualTo: userId)
        .where('productId', isEqualTo: widget.productData['productId'])
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({'quantity': (existing.docs.first['quantity'] ?? 0) + _quantity});
    } else {
      await firestore.collection('cart').add({
        'buyerId': userId, 'productId': widget.productData['productId'], 'name': widget.productData['name'], 'price': widget.productData['price'],
        'quantity': _quantity, 'unit': widget.productData['unit'], 'image': widget.productData['imageUrl'] ?? widget.productData['image'] ?? '',
        'sellerName': widget.productData['seller_name'], 'sellerId': widget.productData['sellerId'] ?? "",
      });
    }

    Fluttertoast.showToast(msg: "${widget.productData['name']} added to cart!", backgroundColor: AppColors.primary);
    if (!mounted) return;
    if (goToCart) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.productData['name'] ?? 'Agro Product';
    
    final priceStr = widget.productData['price']?.toString() ?? '0';
    final double priceVal = double.tryParse(priceStr) ?? 0.0;
    
    final originalPriceStr = widget.productData['originalPrice']?.toString();
    final double? originalPriceVal = originalPriceStr != null ? double.tryParse(originalPriceStr) : null;
    
    bool isOnSale = originalPriceVal != null && originalPriceVal > priceVal;
    int discountPercent = 0;
    if (isOnSale) {
      discountPercent = ((originalPriceVal - priceVal) / originalPriceVal * 100).toInt();
    }

    final unit = widget.productData['unit'] ?? 'kg';
    final imageUrl = widget.productData['imageUrl'] ?? widget.productData['image'] ?? '';
    final category = widget.productData['category'] ?? 'General';
    final description = widget.productData['description'] ?? 'No description available.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 350,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9), 
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary)
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9), 
                  child: const Icon(Icons.favorite_border, color: AppColors.textPrimary)
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9), 
                  child: const Icon(Icons.share, color: AppColors.textPrimary)
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_${widget.productData['productId']}',
                    child: KisanImage(
                      imageSource: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Subtle gradient for better button visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Discount Tags
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1), 
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            category.toUpperCase(), 
                            style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)
                          ),
                        ),
                        if (isOnSale) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.9), 
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Text(
                              "$discountPercent% OFF", 
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.2)),
                    const SizedBox(height: 4),
                    Text(widget.productData['quantity']?.toString() != null ? "Stock Available" : "Fresh Daily", style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    
                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isOnSale)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, bottom: 2),
                            child: Text(
                              "₹$originalPriceStr", 
                              style: const TextStyle(
                                fontSize: 16, 
                                decoration: TextDecoration.lineThrough, 
                                color: AppColors.textSecondary
                              )
                            ),
                          ),
                        Text("₹$priceStr", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(" / $unit", style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              SizedBox(width: 4),
                              Text("4.8", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Commerce Delivery Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0,2))
                              ]
                            ),
                            child: const Icon(Icons.flash_on, color: Colors.amber, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Superfast Delivery", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                SizedBox(height: 2),
                                Text("Get it to your door in 10-15 mins", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Farmer Card
                    const Text("Sold by", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 28, backgroundColor: AppColors.primaryLight, child: Icon(Icons.storefront, color: Colors.white, size: 28)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.productData['seller_name'] ?? 'Local Farmer', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                const SizedBox(height: 4),
                                const Text("Verified Seller • 2.5 km away", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // About
                    const Text("About the product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Text(description, style: TextStyle(fontSize: 15, color: AppColors.textPrimary.withValues(alpha: 0.8), height: 1.6)),
                    
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        height: 100,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
          border: const Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary)
              ),
              child: Row(
                children: [
                  IconButton(onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1), icon: const Icon(Icons.remove, color: AppColors.primary)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addToCart(goToCart: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ADD TO CART", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text("₹${_totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
