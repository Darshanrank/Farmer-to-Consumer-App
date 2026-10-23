import 'package:flutter/material.dart';

class DeliveryDetailsCard extends StatelessWidget {
  final String? deliveryMode;
  final String? deliveryEstimate;
  final String status;
  final String? shippingAddress;
  final String? deliveryStage;
  final Map<String, dynamic>? transportAssignment;

  const DeliveryDetailsCard({
    super.key,
    required this.deliveryMode,
    required this.deliveryEstimate,
    required this.status,
    required this.shippingAddress,
    this.deliveryStage,
    this.transportAssignment,
  });

  @override
  Widget build(BuildContext context) {
    final mode = deliveryMode == 'fast' ? 'Fast Delivery' : 'Regular Delivery';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Mode', value: mode),
            _DetailRow(
              label: 'Estimated window',
              value: deliveryEstimate ?? 'Not available',
            ),
            _DetailRow(label: 'Order status', value: _label(status)),
            _DetailRow(
              label: 'Delivery stage',
              value: _label(deliveryStage ?? _deliveryStageForStatus),
            ),
            _DetailRow(label: 'Transport', value: _transportSummary),
            if (shippingAddress != null && shippingAddress!.isNotEmpty)
              _DetailRow(label: 'Destination', value: shippingAddress!),
          ],
        ),
      ),
    );
  }

  String get _deliveryStageForStatus {
    switch (status) {
      case 'ready':
        return 'Ready for dispatch';
      case 'dispatched':
        return 'In transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
      case 'rejected':
        return status;
      default:
        return 'Awaiting seller fulfilment';
    }
  }

  String get _transportSummary {
    final assignment = transportAssignment;
    if (assignment == null) {
      return 'Transport details will appear after seller assignment.';
    }
    final vehicle = assignment['vehicleNumber'];
    final type = assignment['vehicleType'];
    final driver = assignment['driverName'];
    return [
      if (type is String && type.isNotEmpty) type,
      if (vehicle is String && vehicle.isNotEmpty) vehicle,
      if (driver is String && driver.isNotEmpty) 'Driver: $driver',
      'Live GPS tracking is unavailable.',
    ].join(' • ');
  }

  static String _label(String value) => value
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
