import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;
  final String? deliveryStage;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    this.deliveryStage,
  });

  static const stages = <String>[
    'pending',
    'accepted',
    'preparing',
    'packed',
    'ready',
    'assigned',
    'picked_up',
    'in_transit',
    'dispatched',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = deliveryStage ?? currentStatus;
    final currentIndex = stages.indexOf(effectiveStatus);
    final terminal = {
      'cancelled',
      'rejected',
      'failed',
      'returned',
    }.contains(effectiveStatus);
    return Column(
      children: [
        for (var index = 0; index < stages.length; index++)
          _TimelineRow(
            label: _label(stages[index]),
            isCurrent: stages[index] == effectiveStatus,
            isComplete: !terminal && currentIndex >= index,
            isLast: index == stages.length - 1,
          ),
        if (terminal)
          _TimelineRow(
            label: _label(effectiveStatus),
            isCurrent: true,
            isComplete: false,
            isLast: true,
            isNegative: true,
          ),
      ],
    );
  }

  static String _label(String status) => status
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final bool isCurrent;
  final bool isComplete;
  final bool isLast;
  final bool isNegative;

  const _TimelineRow({
    required this.label,
    required this.isCurrent,
    required this.isComplete,
    required this.isLast,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isNegative
        ? Colors.red
        : isComplete
        ? AppColors.primary
        : Colors.grey.shade400;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(
                  isNegative
                      ? Icons.cancel
                      : isComplete
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: color,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 18),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? color : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
