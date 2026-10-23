import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/order_status_timeline.dart';
import '../../../../core/widgets/delivery_details_card.dart';
import '../providers/seller_orders_provider.dart';
import '../providers/order_status_controller.dart';
import '../../data/seller_order_repository.dart';

class SellerOrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String newStatus,
  ) async {
    final result = await ref
        .read(orderStatusControllerProvider.notifier)
        .updateStatus(orderId: orderId, newStatus: newStatus);

    if (context.mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.exceptionOrNull?.message ?? 'Failed to update status',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignTransport(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    bool isFast,
  ) async {
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _TransportDialog(isFast: isFast),
    );
    if (values == null || !context.mounted) return;
    final result = await ref
        .read(sellerOrderRepositoryProvider)
        .assignTransport(orderId: orderId, transport: values);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Transport assigned'
              : result.exceptionOrNull?.message ??
                    'Transport assignment failed',
        ),
        backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _updateDeliveryStage(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String stage,
  ) async {
    final result = await ref
        .read(sellerOrderRepositoryProvider)
        .updateDeliveryStage(orderId: orderId, stage: stage);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Delivery updated'
              : result.exceptionOrNull?.message ?? 'Delivery update failed',
        ),
        backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);
    final isUpdating = ref.watch(orderStatusControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Status: ${order.status.toUpperCase()}'),
                      if (order.deliveryMode != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Delivery: ${order.deliveryMode == 'fast' ? 'Fast Delivery' : 'Regular Delivery'}',
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (order.deliveryEstimate != null)
                        Text('Estimated delivery: ${order.deliveryEstimate}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Fulfilment and delivery progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                OrderStatusTimeline(
                  currentStatus: order.status,
                  deliveryStage: order.deliveryStage,
                ),
                const SizedBox(height: 12),
                DeliveryDetailsCard(
                  deliveryMode: order.deliveryMode,
                  deliveryEstimate: order.deliveryEstimate,
                  status: order.status,
                  shippingAddress: order.shippingAddress,
                  deliveryStage: order.deliveryStage,
                  transportAssignment: order.transportAssignment,
                ),
                const SizedBox(height: 12),

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
                ...order.items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Qty: ${item.quantity}  |  ₹${item.price} / ${item.unit}',
                      ),
                      trailing: Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                if (isUpdating)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  if (order.status == 'ready' &&
                      order.transportAssignment == null)
                    OutlinedButton(
                      onPressed: () => _assignTransport(
                        context,
                        ref,
                        order.id,
                        order.deliveryMode == 'fast',
                      ),
                      child: const Text('Assign transport'),
                    ),
                  if (order.transportAssignment != null &&
                      order.deliveryStage == 'assigned')
                    OutlinedButton(
                      onPressed: () => _updateDeliveryStage(
                        context,
                        ref,
                        order.id,
                        'picked_up',
                      ),
                      child: const Text('Mark picked up'),
                    ),
                  if (order.deliveryStage == 'picked_up')
                    OutlinedButton(
                      onPressed: () => _updateDeliveryStage(
                        context,
                        ref,
                        order.id,
                        'in_transit',
                      ),
                      child: const Text('Mark in transit'),
                    ),
                  if (order.deliveryStage == 'in_transit')
                    ElevatedButton(
                      onPressed: () => _updateDeliveryStage(
                        context,
                        ref,
                        order.id,
                        'delivered',
                      ),
                      child: const Text('Confirm delivery'),
                    ),
                  if (order.status == 'pending')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'accepted'),
                      child: const Text('Accept Order'),
                    ),
                  if (order.status == 'accepted')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'preparing'),
                      child: const Text('Start Preparing'),
                    ),
                  if (order.status == 'preparing')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'packed'),
                      child: const Text('Mark as Packed'),
                    ),
                  if (order.status == 'packed')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'ready'),
                      child: const Text('Ready for Dispatch'),
                    ),
                  if (order.status == 'ready')
                    ElevatedButton(
                      onPressed: () =>
                          _updateStatus(context, ref, 'dispatched'),
                      child: const Text('Dispatch Order'),
                    ),
                  if (order.status == 'dispatched')
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, 'delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark as Delivered'),
                    ),
                  if (order.status == 'pending' ||
                      order.status == 'accepted' ||
                      order.status == 'preparing') ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _updateStatus(context, ref, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
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

class _TransportDialog extends StatefulWidget {
  final bool isFast;

  const _TransportDialog({required this.isFast});

  @override
  State<_TransportDialog> createState() => _TransportDialogState();
}

class _TransportDialogState extends State<_TransportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _driver = TextEditingController();
  final _phone = TextEditingController();
  final _vehicleType = TextEditingController();
  final _vehicleNumber = TextEditingController();

  @override
  void dispose() {
    _driver.dispose();
    _phone.dispose();
    _vehicleType.dispose();
    _vehicleNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign seller-managed transport'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_driver, 'Driver name'),
              _field(_phone, 'Driver phone (optional)', required: false),
              _field(_vehicleType, 'Vehicle type'),
              _field(_vehicleNumber, 'Vehicle number'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'transportType': widget.isFast
                  ? 'seller_managed_fast'
                  : 'seller_managed_regular',
              'driverName': _driver.text.trim(),
              'driverPhone': _phone.text.trim(),
              'vehicleType': _vehicleType.text.trim(),
              'vehicleNumber': _vehicleNumber.text.trim(),
            });
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? '$label is required'
                : null
          : null,
    );
  }
}
