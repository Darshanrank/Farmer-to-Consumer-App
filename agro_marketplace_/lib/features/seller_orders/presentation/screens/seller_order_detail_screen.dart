import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/seller_orders_provider.dart';
import '../providers/order_status_controller.dart';

class SellerOrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String newStatus) async {
    final result = await ref.read(orderStatusControllerProvider.notifier).updateStatus(
      orderId: orderId,
      newStatus: newStatus,
    );
    
    if (context.mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.exceptionOrNull?.message ?? 'Failed to update status'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);
    final isUpdating = ref.watch(orderStatusControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (orders) {
          final order = orders.firstWhere(
            (o) => o.id == orderId,
            orElse: () => throw Exception('Order not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text('Status: ${order.status.toUpperCase()}'),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Shipping Address
                const Text(
                  'Shipping Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  order.shippingAddress,
                  style: TextStyle(color: Colors.grey[800], height: 1.5),
                ),
                const SizedBox(height: 24),

                // Items List
                const Text(
                  'Items to Fulfill',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...order.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Qty: ${item.quantity}  |  ₹${item.price} / ${item.unit}'),
                        trailing: Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                      ),
                    )),
                const SizedBox(height: 32),

                // Actions
                if (isUpdating)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  if (order.status == 'pending')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'processing'),
                      child: const Text('Accept & Start Processing'),
                    ),
                  if (order.status == 'processing')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'shipped'),
                      child: const Text('Mark as Shipped'),
                    ),
                  if (order.status == 'shipped')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'delivered'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Mark as Delivered'),
                    ),
                  if (order.status == 'pending') ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _updateStatus(context, ref, 'cancelled'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Decline Order'),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
