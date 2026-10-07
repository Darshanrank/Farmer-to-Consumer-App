import 'package:flutter_test/flutter_test.dart';
import 'package:agro_marketplace/shared/services/geocoding_service.dart';

void main() {
  group('GeocodedAddress', () {
    test('reports isEmpty and isNotEmpty correctly', () {
      const empty = GeocodedAddress();
      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);

      const withState = GeocodedAddress(state: 'Gujarat');
      expect(withState.isEmpty, isFalse);
      expect(withState.isNotEmpty, isTrue);
    });

    test('toString includes formatted fields', () {
      const address = GeocodedAddress(
        line1: '123 MG Road',
        village: 'Ahmedabad',
        district: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380015',
      );
      expect(address.toString(), contains('123 MG Road'));
      expect(address.toString(), contains('Gujarat'));
      expect(address.toString(), contains('380015'));
    });
  });
}
