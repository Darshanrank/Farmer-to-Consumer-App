import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// Colored status badge for displaying entity statuses.
///
/// Maps status strings to appropriate colors automatically.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  /// Creates a status badge with automatic color mapping.
  factory StatusBadge.fromStatus(String status) {
    final (bgColor, fgColor) = _colorsForStatus(status);
    return StatusBadge(
      label: _formatLabel(status),
      color: bgColor,
      textColor: fgColor,
    );
  }

  static (Color, Color) _colorsForStatus(String status) => switch (status) {
    'active' || 'delivered' || 'verified' || 'paid' =>
      (AppColors.successLight, AppColors.success),
    'pending' || 'processing' || 'preparing' || 'verification_pending' =>
      (AppColors.warningLight, AppColors.warning),
    'rejected' || 'cancelled' || 'failed' || 'suspended' =>
      (AppColors.errorLight, AppColors.error),
    'draft' || 'inactive' || 'deactivated' =>
      (const Color(0xFFF5F5F5), AppColors.textTertiary),
    'placed' || 'accepted' || 'dispatched' =>
      (AppColors.infoLight, AppColors.info),
    _ => (AppColors.surfaceVariant, AppColors.textSecondary),
  };

  static String _formatLabel(String status) =>
      status.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
      ).join(' ');

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.surfaceVariant;
    final fgColor = textColor ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
