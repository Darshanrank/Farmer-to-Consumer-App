import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/commerce/product_listing_rules.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/checkout_controller.dart';
import '../providers/shopping_providers.dart';
import '../../domain/entities/checkout_quote.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DetailedAddress? _selectedAddress;

  Future<void> _placeOrder() async {
    final selectedAddress =
        _selectedAddress ?? ref.read(selectedDeliveryAddressProvider);
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a saved delivery address before checkout.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final result = await ref
        .read(checkoutControllerProvider.notifier)
        .placeOrder(
          shippingAddress: selectedAddress.displayAddress,
          buyerAddress: selectedAddress,
        );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Go back to home after successful order
        context.goNamed(RouteNames.buyerHome);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.exceptionOrNull?.message ?? 'Failed to place order',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutControllerProvider);
    final quoteState = ref.watch(checkoutQuoteProvider);
    final total = ref.watch(cartTotalProvider);
    final isLoading = checkoutState.isLoading;
    final user = ref.watch(appUserProvider).value;
    final addresses =
        user?.savedAddresses.map(DetailedAddress.fromMap).toList() ??
        const <DetailedAddress>[];
    final selectedAddress =
        _selectedAddress ?? ref.watch(selectedDeliveryAddressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delivery Address',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose where your order should be delivered.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Add and select a saved address to continue.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.pushNamed(RouteNames.addSavedAddress),
                      child: const Text('Add delivery address'),
                    ),
                  ],
                )
              else
                ...addresses.map(
                  (address) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: selectedAddress == address
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: selectedAddress == address
                            ? AppColors.primary
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: ListTile(
                      onTap: isLoading
                          ? null
                          : () {
                              final index = addresses.indexOf(address);
                              ref
                                  .read(
                                    selectedDeliveryAddressIndexProvider
                                        .notifier,
                                  )
                                  .select(index);
                              setState(() => _selectedAddress = address);
                            },
                      leading: Icon(
                        selectedAddress == address
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selectedAddress == address
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                      title: Text(address.recipientName ?? 'Delivery address'),
                      subtitle: Text(
                        '${address.displayAddress}\n'
                        '${address.hasLocation ? 'Fast Delivery available' : 'Regular Delivery only'}',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              SegmentedButton<ProductListingMode>(
                segments: const [
                  ButtonSegment(
                    value: ProductListingMode.fast,
                    label: Text('Fast Delivery'),
                  ),
                  ButtonSegment(
                    value: ProductListingMode.regular,
                    label: Text('Regular Delivery'),
                  ),
                ],
                selected: {ref.watch(productListingModeControllerProvider)},
                onSelectionChanged: isLoading
                    ? null
                    : (selection) => ref
                          .read(productListingModeControllerProvider.notifier)
                          .select(selection.first),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _QuoteSummary(
                      quote: quoteState.asData?.value,
                      fallbackSubtotal: total,
                    ),
                    if (quoteState.hasError)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ErrorHandler.getUserMessage(quoteState.error!),
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Place Order',
                onPressed: _placeOrder,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteSummary extends StatelessWidget {
  final CheckoutQuote? quote;
  final double fallbackSubtotal;

  const _QuoteSummary({required this.quote, required this.fallbackSubtotal});

  @override
  Widget build(BuildContext context) {
    final subtotal = quote?.subtotal ?? fallbackSubtotal;
    final discount = quote?.discount ?? 0;
    final tax = quote?.tax ?? 0;
    final handling = quote?.handlingFee ?? 0;
    final delivery = quote?.deliveryFee;
    final total =
        quote?.total ??
        (delivery == null
            ? null
            : subtotal - discount + tax + handling + delivery);
    return Column(
      children: [
        _ChargeRow(label: 'Subtotal', amount: subtotal),
        _ChargeRow(label: 'Discount', amount: -discount),
        _ChargeRow(label: 'Tax', amount: tax),
        _ChargeRow(label: 'Handling Fee', amount: handling),
        if (delivery != null)
          _ChargeRow(label: 'Delivery Fee', amount: delivery),
        if (delivery == null)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Delivery fee is being calculated...'),
          ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              total == null ? 'Calculating...' : '₹${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        if (quote == null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Final charges will be revalidated at confirmation.'),
          ),
      ],
    );
  }
}

class _ChargeRow extends StatelessWidget {
  final String label;
  final double amount;

  const _ChargeRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('₹${amount.toStringAsFixed(2)}')],
      ),
    );
  }
}
