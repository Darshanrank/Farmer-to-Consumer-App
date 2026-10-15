import '../../shared/models/detailed_address.dart';
import 'validators.dart';

enum DeliveryAddressValidationFailure {
  recipientNameMissing,
  phoneMissing,
  phoneInvalid,
  addressLineMissing,
  cityMissing,
  stateMissing,
  postalCodeMissing,
  postalCodeInvalid,
  countryCodeMissing,
  coordinatesInvalid,
}

class DeliveryAddressValidationResult {
  final DeliveryAddressValidationFailure? failure;

  const DeliveryAddressValidationResult.valid() : failure = null;
  const DeliveryAddressValidationResult.invalid(this.failure);

  bool get isValid => failure == null;
}

class DeliveryAddressValidator {
  const DeliveryAddressValidator._();

  static DeliveryAddressValidationResult validate(DetailedAddress address) {
    if (_blank(address.recipientName)) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.recipientNameMissing,
      );
    }
    if (_blank(address.phoneNumber)) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.phoneMissing,
      );
    }
    if (Validators.phone(address.phoneNumber) != null) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.phoneInvalid,
      );
    }
    if (_blank(address.address.line1)) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.addressLineMissing,
      );
    }
    if (_blank(address.address.city)) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.cityMissing,
      );
    }
    if (address.address.state.trim().isEmpty) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.stateMissing,
      );
    }
    if (address.address.pincode.trim().isEmpty) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.postalCodeMissing,
      );
    }
    if (Validators.pincode(address.address.pincode) != null) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.postalCodeInvalid,
      );
    }
    if (address.address.normalizedCountryCode == null) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.countryCodeMissing,
      );
    }
    if (address.location != null && !address.location!.isValid) {
      return const DeliveryAddressValidationResult.invalid(
        DeliveryAddressValidationFailure.coordinatesInvalid,
      );
    }
    return const DeliveryAddressValidationResult.valid();
  }

  static bool _blank(String? value) => value == null || value.trim().isEmpty;
}
