/// Reusable field validators for forms and data validation.
///
/// These validators are used at the UI level (form fields) and also
/// invoked before repository calls for application-level validation.
///
/// Each validator returns null if valid, or an error message string if invalid.
class Validators {
  const Validators._();

  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates Indian phone number (10 digits, starting with 6-9).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    // Remove country code prefix if present
    final digits = cleaned.startsWith('91') && cleaned.length == 12
        ? cleaned.substring(2)
        : cleaned;
    if (digits.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Please enter a valid Indian phone number';
    }
    return null;
  }

  /// Validates Indian pincode (6 digits).
  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }

  /// Validates that a numeric value is positive.
  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    return null;
  }

  /// Validates minimum and maximum length.
  static String? length(
    String? value, {
    required int min,
    int? max,
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    if (max != null && value.trim().length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Validates that the selling price does not exceed MRP.
  static String? sellingPrice(String? value, double mrp) {
    final baseError = positiveNumber(value, 'Selling price');
    if (baseError != null) return baseError;
    final price = double.parse(value!.trim());
    if (price > mrp) {
      return 'Selling price cannot exceed MRP (₹${mrp.toStringAsFixed(2)})';
    }
    return null;
  }

  /// Validates password confirmation matches.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates GST number format (15-character alphanumeric).
  static String? gstNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid GST number';
    }
    return null;
  }

  /// Validates PAN number format (10-character alphanumeric).
  static String? panNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid PAN number';
    }
    return null;
  }
}
