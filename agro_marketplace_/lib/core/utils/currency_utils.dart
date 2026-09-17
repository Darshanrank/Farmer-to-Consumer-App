import 'package:intl/intl.dart';

/// Currency formatting utilities for Indian Rupee.
class CurrencyUtils {
  const CurrencyUtils._();

  static final _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _indianFormatNoDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats as ₹1,23,456.78
  static String format(double amount) => _indianFormat.format(amount);

  /// Formats as ₹1,23,457 (no decimals)
  static String formatRounded(double amount) =>
      _indianFormatNoDecimals.format(amount);

  /// Formats with compact notation (e.g., ₹1.2L, ₹50K)
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
