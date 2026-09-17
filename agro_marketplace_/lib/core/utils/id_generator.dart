import 'package:uuid/uuid.dart';

/// Utility for generating unique identifiers.
class IdGenerator {
  static const _uuid = Uuid();

  const IdGenerator._();

  /// Generates a UUID v4 string.
  static String generate() => _uuid.v4();

  /// Generates a short ID (first 8 chars of UUID).
  static String generateShort() => _uuid.v4().substring(0, 8);

  /// Generates a human-readable order number.
  ///
  /// Format: AGM-{timestamp_suffix}-{random}
  /// Example: AGM-2609-A3F8
  static String generateOrderNumber() {
    final now = DateTime.now();
    final datePart = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}';
    final randomPart = _uuid.v4().substring(0, 4).toUpperCase();
    return 'AGM-$datePart-$randomPart';
  }
}
