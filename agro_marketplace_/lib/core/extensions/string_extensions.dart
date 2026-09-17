/// String extensions for common operations.
extension StringExtensions on String {
  /// Capitalizes the first letter.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Converts 'some_status' to 'Some Status'.
  String get toDisplayCase =>
      split('_').map((word) => word.capitalize).join(' ');

  /// Whether the string is a valid email format.
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);

  /// Whether the string is a valid Indian phone number.
  bool get isValidIndianPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    final digits = cleaned.startsWith('91') && cleaned.length == 12
        ? cleaned.substring(2)
        : cleaned;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }

  /// Whether the string is a valid 6-digit pincode.
  bool get isValidPincode => RegExp(r'^\d{6}$').hasMatch(trim());

  /// Truncates to [maxLength] with ellipsis.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  /// Masks sensitive content (e.g., bank account, phone).
  String get masked {
    if (length <= 4) return '****';
    return '${'*' * (length - 4)}${substring(length - 4)}';
  }
}

/// Nullable string extension.
extension NullableStringExtensions on String? {
  /// Whether the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Whether the string has content.
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
