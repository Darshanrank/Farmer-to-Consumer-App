import '../../shared/models/location.dart';

class DeliverySettingsValidator {
  const DeliverySettingsValidator._();

  static String? validate({
    required bool fastEnabled,
    required bool regularEnabled,
    required GeoLocation? origin,
    required String countryCode,
    required int? fastMinDays,
    required int? fastMaxDays,
    required int? regularMinDays,
    required int? regularMaxDays,
    required double? fastFee,
    required double? regularFee,
  }) {
    if (countryCode.trim().length != 2 ||
        !RegExp(r'^[A-Za-z]{2}$').hasMatch(countryCode.trim())) {
      return 'Enter a valid two-letter country code.';
    }
    if ((fastEnabled || regularEnabled) && origin?.isValid != true) {
      return 'A valid delivery origin is required.';
    }
    if (fastEnabled && !_validWindow(fastMinDays, fastMaxDays, maximum: 7)) {
      return 'Fast Delivery estimates must be between 1 and 7 days.';
    }
    if (regularEnabled &&
        !_validWindow(regularMinDays, regularMaxDays, maximum: 7)) {
      return 'Regular Delivery estimates must be between 1 and 7 days.';
    }
    if (!_validFee(fastFee) || !_validFee(regularFee)) {
      return 'Delivery fees must be valid non-negative numbers.';
    }
    return null;
  }

  static bool _validWindow(int? min, int? max, {required int maximum}) =>
      min != null && max != null && min >= 1 && max >= min && max <= maximum;

  static bool _validFee(double? fee) => fee == null || fee.isFinite && fee >= 0;
}
