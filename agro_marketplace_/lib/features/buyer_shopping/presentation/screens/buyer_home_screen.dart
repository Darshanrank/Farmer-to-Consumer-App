import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/commerce/delivery_fee.dart';
import '../../../../core/commerce/product_listing_rules.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/shopping_providers.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(buyerProductsProvider);
    final products = ref.watch(buyerListingProductsProvider);
    final mode = ref.watch(productListingModeControllerProvider);
    final user = ref.watch(appUserProvider).value;
    final selectedAddress = ref.watch(selectedDeliveryAddressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agro Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<ProductListingMode>(
                  segments: const [
                    ButtonSegment(
                      value: ProductListingMode.fast,
                      label: Text('Fast'),
                      icon: Icon(Icons.bolt),
                    ),
                    ButtonSegment(
                      value: ProductListingMode.regular,
                      label: Text('Regular'),
                      icon: Icon(Icons.local_shipping_outlined),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (selection) => ref
                      .read(productListingModeControllerProvider.notifier)
                      .select(selection.first),
                ),
              ),
              IconButton(
                tooltip: 'Choose delivery address',
                onPressed: user == null || user.savedAddresses.isEmpty
                    ? null
                    : () => _selectAddress(
                        context,
                        ref,
                        user.savedAddresses.length,
                      ),
                icon: Icon(
                  selectedAddress == null
                      ? Icons.location_off_outlined
                      : Icons.location_on_outlined,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search products',
            icon: const Icon(Icons.search),
            onPressed: () {
              context.pushNamed(RouteNames.buyerSearch);
            },
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => _MessageState(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load products',
          message: 'Check your connection and try again.',
          action: TextButton(
            onPressed: () => ref.invalidate(buyerProductsProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (_) {
          if (products.isEmpty) {
            return _MessageState(
              icon: mode == ProductListingMode.fast
                  ? Icons.location_off_outlined
                  : Icons.local_shipping_outlined,
              title: 'No products available',
              message:
                  mode == ProductListingMode.fast && selectedAddress == null
                  ? 'Choose a saved delivery address to see eligible products.'
                  : mode == ProductListingMode.fast &&
                        selectedAddress?.location?.isValid != true
                  ? 'Fast Delivery needs valid coordinates on the selected address.'
                  : 'No configured sellers currently meet this delivery mode.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.50,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(
                        RouteNames.buyerProductDetail,
                        pathParameters: {'id': product.id},
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              product.images.isNotEmpty
                                  ? Image.memory(
                                      product.images.first.data,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      color: Colors.grey[100],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Details
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.availabilityLabel,
                                      style: TextStyle(
                                        color: product.isAvailableForPurchase
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${mode == ProductListingMode.fast ? 'Fast Delivery' : 'Regular Delivery'}'
                                      '${ProductListingRules.evaluate(product: product, mode: mode, buyerAddress: selectedAddress).deliveryWindow == null ? '' : ' • ${ProductListingRules.evaluate(product: product, mode: mode, buyerAddress: selectedAddress).deliveryWindow}'}',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Delivery fee: ₹${deliveryFeeForMode(product: product, mode: mode).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.category,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${product.price}/${product.unit}',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectAddress(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Delivery address'),
        children: List.generate(
          count,
          (index) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, index),
            child: Text('Saved address ${index + 1}'),
          ),
        ),
      ),
    );
    if (selected != null) {
      ref.read(selectedDeliveryAddressIndexProvider.notifier).select(selected);
    }
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
