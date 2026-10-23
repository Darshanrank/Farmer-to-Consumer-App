import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:agro_marketplace/core/commerce/product_listing_rules.dart';
import 'package:agro_marketplace/features/seller_inventory/domain/entities/product.dart';
import 'package:agro_marketplace/shared/models/address.dart';
import 'package:agro_marketplace/shared/models/detailed_address.dart';
import 'package:agro_marketplace/shared/models/location.dart';

void main() {
  final sellerLocation = const GeoLocation(latitude: 0, longitude: 0);

  Product product({
    bool fast = false,
    bool regular = false,
    bool sellerManaged = false,
    String? country = 'IN',
  }) {
    return Product(
      id: 'product-1',
      sellerId: 'seller-1',
      name: 'Test product',
      description: 'Test',
      price: 10,
      unit: 'kg',
      stockQuantity: 10,
      category: 'Seeds',
      supportsFastDelivery: fast,
      supportsRegularDelivery: regular,
      sellerManagedFastDelivery: sellerManaged,
      sellerCountryCode: country,
      sellerServiceLocation: sellerLocation,
      fastDeliveryMinDays: 1,
      fastDeliveryMaxDays: 2,
      regularDeliveryMinDays: 2,
      regularDeliveryMaxDays: 7,
    );
  }

  DetailedAddress address({String country = 'IN', GeoLocation? location}) {
    return DetailedAddress(
      address: Address(
        state: 'Gujarat',
        pincode: '380001',
        countryCode: country,
      ),
      location: location,
    );
  }

  test('includes Fast Delivery at exactly 60 km', () {
    final latitudeAt60Km = 60 / 6371.0088 * 180 / math.pi;
    final result = ProductListingRules.evaluate(
      product: product(fast: true, sellerManaged: true),
      mode: ProductListingMode.fast,
      buyerAddress: address(
        location: GeoLocation(latitude: latitudeAt60Km, longitude: 0),
      ),
    );
    expect(result.isEligible, isTrue);
    expect(result.deliveryWindow, '1–2 days');
  });

  test('rejects Fast Delivery beyond 60 km and without coordinates', () {
    final beyond = ProductListingRules.evaluate(
      product: product(fast: true, sellerManaged: true),
      mode: ProductListingMode.fast,
      buyerAddress: address(
        location: const GeoLocation(latitude: 0.55, longitude: 0),
      ),
    );
    expect(beyond.isEligible, isFalse);

    final missing = ProductListingRules.evaluate(
      product: product(fast: true, sellerManaged: true),
      mode: ProductListingMode.fast,
      buyerAddress: address(),
    );
    expect(missing.reason, contains('coordinates'));
  });

  test(
    'requires seller mode support but not a buyer address for regular delivery',
    () {
      final disabled = ProductListingRules.evaluate(
        product: product(regular: false),
        mode: ProductListingMode.regular,
        buyerAddress: address(),
      );
      expect(disabled.isEligible, isFalse);

      final mismatch = ProductListingRules.evaluate(
        product: product(regular: true, country: 'US'),
        mode: ProductListingMode.regular,
        buyerAddress: address(),
      );
      expect(mismatch.isEligible, isTrue);

      final eligible = ProductListingRules.evaluate(
        product: product(regular: true),
        mode: ProductListingMode.regular,
        buyerAddress: null,
      );
      expect(eligible.isEligible, isTrue);
    },
  );

  test('supports a product eligible for either mode', () {
    final item = product(fast: true, regular: true, sellerManaged: true);
    expect(
      ProductListingRules.evaluate(
        product: item,
        mode: ProductListingMode.fast,
        buyerAddress: address(
          location: const GeoLocation(latitude: 0, longitude: 0),
        ),
      ).isEligible,
      isTrue,
    );
    expect(
      ProductListingRules.evaluate(
        product: item,
        mode: ProductListingMode.regular,
        buyerAddress: address(),
      ).isEligible,
      isTrue,
    );
  });
}
