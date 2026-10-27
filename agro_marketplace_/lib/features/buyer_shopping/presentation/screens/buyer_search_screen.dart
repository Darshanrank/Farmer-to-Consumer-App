import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/commerce/delivery_fee.dart';
import '../../../../core/commerce/product_listing_rules.dart';
import '../../../../core/widgets/app_message_state.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/search_providers.dart';
import '../providers/shopping_providers.dart';

class BuyerSearchScreen extends ConsumerStatefulWidget {
  const BuyerSearchScreen({super.key});

  @override
  ConsumerState<BuyerSearchScreen> createState() => _BuyerSearchScreenState();
}

class _BuyerSearchScreenState extends ConsumerState<BuyerSearchScreen> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(buyerProductsProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final mode = ref.watch(productListingModeControllerProvider);
    final selectedAddress = ref.watch(selectedDeliveryAddressProvider);
    final user = ref.watch(appUserProvider).value;

    const categories = [
      'Seeds',
      'Fertilizers',
      'Crop Protection',
      'Machinery & Equipment',
      'Irrigation',
      'Tools',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search agro products...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _queryController.clear();
                ref.read(searchQueryProvider.notifier).updateQuery('');
              },
            ),
          ),
          controller: _queryController,
          onChanged: (val) {
            ref.read(searchQueryProvider.notifier).updateQuery(val);
          },
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onSelectionChanged: (selection) => ref
                        .read(productListingModeControllerProvider.notifier)
                        .select(selection.first),
                  ),
                ),
                IconButton(
                  tooltip: 'Choose delivery address',
                  onPressed: user == null || user.savedAddresses.isEmpty
                      ? null
                      : () async {
                          final index = await showDialog<int>(
                            context: context,
                            builder: (dialogContext) => SimpleDialog(
                              title: const Text('Delivery address'),
                              children: List.generate(
                                user.savedAddresses.length,
                                (index) => SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, index),
                                  child: Text(
                                    DetailedAddress.fromMap(
                                      user.savedAddresses[index],
                                    ).shortAddress,
                                  ),
                                ),
                              ),
                            ),
                          );
                          if (index != null) {
                            ref
                                .read(
                                  selectedDeliveryAddressIndexProvider.notifier,
                                )
                                .select(index);
                          }
                        },
                  icon: Icon(
                    selectedAddress == null
                        ? Icons.location_off_outlined
                        : Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
          ),
          // Category Filters
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedCategory == null;
                  return ChoiceChip(
                    label: const Text('All'),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onSelected: (selected) {
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .selectCategory(null);
                    },
                  );
                }

                final category = categories[index - 1];
                final isSelected = selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  onSelected: (selected) {
                    ref
                        .read(selectedCategoryProvider.notifier)
                        .selectCategory(selected ? category : null);
                  },
                );
              },
            ),
          ),

          // Results
          Expanded(
            child: productsAsync.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : productsAsync.hasError
                ? _SearchErrorState(
                    onRetry: () => ref.invalidate(buyerProductsProvider),
                  )
                : filteredProducts.isEmpty
                ? const AppMessageState(
                    icon: Icons.search_off_outlined,
                    title: 'No products found',
                    message:
                        'Try a different search term or clear the filters.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: product.images.isNotEmpty
                                    ? Image.memory(
                                        product.images.first.data,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${product.price} / ${product.unit}',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.availabilityLabel,
                                      style: TextStyle(
                                        color: product.isAvailableForPurchase
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${mode == ProductListingMode.fast ? 'Fast Delivery' : 'Regular Delivery'} • ${ProductListingRules.evaluate(product: product, mode: mode, buyerAddress: selectedAddress).deliveryWindow}',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Delivery fee: ₹${deliveryFeeForMode(product: product, mode: mode).toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _SearchErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('Could not load products.'),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
