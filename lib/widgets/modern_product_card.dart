import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';

class ModernProductCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onAdd;
  final int index;

  const ModernProductCard({
    super.key,
    required this.data,
    required this.onAdd,
    this.index = 0,
  });

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceStr = widget.data['price']?.toString() ?? '0';
    final double priceVal = double.tryParse(priceStr) ?? 0.0;
    
    final originalPriceStr = widget.data['originalPrice']?.toString();
    final double? originalPriceVal = originalPriceStr != null ? double.tryParse(originalPriceStr) : null;
    
    bool isOnSale = originalPriceVal != null && originalPriceVal > priceVal;
    int discountPercent = 0;
    if (isOnSale) {
      discountPercent = ((originalPriceVal - priceVal) / originalPriceVal * 100).toInt();
    }

    final name = widget.data['name'] ?? 'Product';
    final unit = widget.data['unit'] ?? 'kg';
    final imageUrl = widget.data['imageUrl'] ?? widget.data['image'] ?? '';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: KisanImage(
                            imageSource: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOnSale ? Colors.red.withValues(alpha: 0.9) : AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOnSale ? "$discountPercent% OFF" : "FRESH",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isOnSale)
                              Text(
                                "₹$originalPriceStr",
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            Text(
                              "₹$priceStr",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // AppColors.primary.withOpacity(0.1) could be used if wanted filled
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: widget.onAdd,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: Text(
                                  "ADD",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
