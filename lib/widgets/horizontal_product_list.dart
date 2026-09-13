import 'package:flutter/material.dart';
import 'package:kisanbazaar/models/product_model.dart';
import 'package:kisanbazaar/widgets/modern_product_card.dart';
import 'package:kisanbazaar/services/cart_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class HorizontalProductList extends StatelessWidget {
  final Stream<List<ProductModel>> productStream;
  final String title;

  const HorizontalProductList({
    super.key,
    required this.productStream,
    required this.title,
  });

  void addToCart(ProductModel product) async {
    final CartService cartService = CartService();
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Fluttertoast.showToast(msg: "Please login to add to cart");
      return;
    }
    await cartService.addToCart(buyerId: userId, productData: product.toJson());
    Fluttertoast.showToast(msg: "${product.name} added to cart!", backgroundColor: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              TextButton(
                onPressed: () {},
                child: const Text("See All", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: StreamBuilder<List<ProductModel>>(
            stream: productStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No products currently.", style: TextStyle(color: AppColors.textSecondary)));
              }

              var products = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ModernProductCard(
                      data: products[index].toJson(),
                      onAdd: () => addToCart(products[index]),
                      index: index,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
