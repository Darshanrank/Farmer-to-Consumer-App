import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/screens/buyer/checkout_screen.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';
import 'package:kisanbazaar/models/cart_item_model.dart';
import 'package:kisanbazaar/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  final CartService _cartService = CartService();

  void _updateQuantity(String cartItemId, int newQuantity, String productId) async {
    if (newQuantity <= 0) {
      await _cartService.removeFromCart(cartItemId);
    } else {
      await _cartService.updateQuantity(cartItemId, newQuantity);
    }
  }

  double _calculateTotal(List<CartItemModel> items) {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: userId != null ? _cartService.streamCartItems(userId!) : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

          var cartItems = snapshot.data!;
          double subtotal = _calculateTotal(cartItems);
          double deliveryFee = subtotal > 500 ? 0 : 40;
          double total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text("Delivery in 10-15 mins", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1),
                          ),
                          ...cartItems.map((doc) => _buildCartItem(doc)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBillDetails(subtotal, deliveryFee, total),
                    const SizedBox(height: 40),
                    // Trust Banner
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text("100% Secure Payments", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
              _buildBottomBar(total, cartItems),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle
            ),
            child: Icon(Icons.shopping_basket_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          const Text("Your cart is empty", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text("Add items to your cart to see them here", style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text("BROWSE PRODUCTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: KisanImage(
                imageSource: item.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("${item.price} / ${item.unit}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text("₹${item.price * item.quantity}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary)
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _updateQuantity(item.cartItemId, item.quantity - 1, item.productId),
                  icon: const Icon(Icons.remove, size: 16, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                ),
                Text("${item.quantity}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed: () => _updateQuantity(item.cartItemId, item.quantity + 1, item.productId),
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(double subtotal, double delivery, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bill Details", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 20),
          _billRow("Item Total", "₹${subtotal.toStringAsFixed(0)}", icon: Icons.receipt_long_outlined),
          const SizedBox(height: 12),
          _billRow("Delivery Fee", delivery == 0 ? "FREE" : "₹${delivery.toStringAsFixed(0)}", isFree: delivery == 0, icon: Icons.moped_outlined),
          const SizedBox(height: 12),
          _billRow("Handling Fee", "₹2", icon: Icons.shopping_bag_outlined), // Mocked for realism
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          _billRow("Grand Total", "₹${(total + 2).toStringAsFixed(0)}", isTotal: true),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isFree = false, bool isTotal = false, IconData? icon}) {
    return Row(
      children: [
        if (icon != null && !isTotal) ...[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
        ],
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500, fontSize: isTotal ? 18 : 14, color: isTotal ? AppColors.textPrimary : AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isTotal ? 18 : 14, color: isFree ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildBottomBar(double total, List<CartItemModel> items) {
    double grandTotal = total + 2; // Including mocked handling fee
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                List<Map<String, dynamic>> cartData = items.map((item) => item.toJson()).toList();
                Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(cartItems: cartData, totalAmount: grandTotal)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 64), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹${grandTotal.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const Text("TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                    ],
                  ),
                  Row(
                    children: const [
                      Text("Proceed to Checkout", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16)
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
