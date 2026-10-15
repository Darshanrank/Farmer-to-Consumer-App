import 'package:flutter_test/flutter_test.dart';

import 'package:agro_marketplace/core/validation/delivery_settings_validator.dart';
import 'package:agro_marketplace/shared/models/location.dart';

void main() {
  const origin = GeoLocation(latitude: 23.02, longitude: 72.57);

  test('requires origin and valid estimates for enabled modes', () {
    expect(
      DeliverySettingsValidator.validate(
        fastEnabled: true,
        regularEnabled: false,
        origin: null,
        countryCode: 'IN',
        fastMinDays: 1,
        fastMaxDays: 2,
        regularMinDays: null,
        regularMaxDays: null,
        fastFee: null,
        regularFee: null,
      ),
      isNotNull,
    );
    expect(
      DeliverySettingsValidator.validate(
        fastEnabled: true,
        regularEnabled: false,
        origin: origin,
        countryCode: 'IN',
        fastMinDays: 0,
        fastMaxDays: 2,
        regularMinDays: null,
        regularMaxDays: null,
        fastFee: null,
        regularFee: null,
      ),
      isNotNull,
    );
  });

  test('accepts valid seller-managed settings', () {
    expect(
      DeliverySettingsValidator.validate(
        fastEnabled: true,
        regularEnabled: true,
        origin: origin,
        countryCode: ' in ',
        fastMinDays: 1,
        fastMaxDays: 2,
        regularMinDays: 2,
        regularMaxDays: 7,
        fastFee: 10,
        regularFee: 0,
      ),
      isNull,
    );
  });

  test('rejects malformed country and fees', () {
    expect(
      DeliverySettingsValidator.validate(
        fastEnabled: false,
        regularEnabled: false,
        origin: null,
        countryCode: 'IND',
        fastMinDays: null,
        fastMaxDays: null,
        regularMinDays: null,
        regularMaxDays: null,
        fastFee: -1,
        regularFee: null,
      ),
      isNotNull,
    );
  });
}
