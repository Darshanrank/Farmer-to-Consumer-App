import 'package:flutter_test/flutter_test.dart';

import 'package:agro_marketplace/core/commerce/commerce_rules.dart';
import 'package:agro_marketplace/core/enums/delivery_type.dart';
import 'package:agro_marketplace/features/seller_inventory/domain/entities/product.dart';
import 'package:agro_marketplace/shared/models/address.dart';
import 'package:agro_marketplace/shared/models/detailed_address.dart';
import 'package:agro_marketplace/shared/models/location.dart';

void main() {
  final sellerAddress = DetailedAddress(
    address: const Address(
      state: 'Gujarat',
      pincode: '380001',
      countryCode: 'in',
    ),
    location: const GeoLocation(latitude: 23.0225, longitude: 72.5714),
  );

  Product product({
    bool fast = false,
    bool regular = false,
    int stock = 10,
    int reserved = 0,
    int sold = 0,
  }) {
    return Product(
      id: 'product-1',
      sellerId: 'seller-1',
      name: 'Seeds',
      description: 'Test product',
      price: 10,
      unit: 'kg',
      stockQuantity: stock,
      category: 'Seeds',
      supportsFastDelivery: fast,
      supportsRegularDelivery: regular,
      reservedQuantity: reserved,
      soldQuantity: sold,
    );
  }

  group('Address country normalization', () {
    test('normalizes valid country codes and rejects invalid values', () {
      expect(Address.normalizeCountryCode(' in '), 'IN');
      expect(Address.normalizeCountryCode('IND'), isNull);
      expect(Address.normalizeCountryCode(null), isNull);
    });
  });

  group('InventoryRules', () {
    test('treats zero or malformed inventory as unavailable', () {
      expect(product(stock: 0).isAvailableForPurchase, isFalse);
      expect(
        Product.fromJson({
          'id': 'legacy',
          'sellerId': 'seller-1',
          'name': 'Legacy product',
          'description': 'Legacy',
          'price': 10,
          'unit': 'kg',
          'stockQuantity': 'not-a-number',
          'category': 'Seeds',
        }).isAvailableForPurchase,
        isFalse,
      );
    });

    test('rejects invalid minimum order quantity', () {
      expect(
        InventoryRules.validateProductForSale(
          product().copyWith(minOrderQuantity: 0),
        ),
        isNotNull,
      );
    });

    test('rejects non-positive quantities', () {
      expect(
        InventoryRules.validateQuantity(product: product(), quantity: 0),
        isNotNull,
      );
      expect(
        InventoryRules.validateQuantity(product: product(), quantity: -1),
        isNotNull,
      );
    });

    test('subtracts reserved and sold quantities from available stock', () {
      final item = product(stock: 10, reserved: 3, sold: 2);
      expect(item.availableQuantity, 5);
      expect(
        InventoryRules.validateQuantity(product: item, quantity: 6),
        isNotNull,
      );
      expect(
        InventoryRules.validateQuantity(product: item, quantity: 5),
        isNull,
      );
    });

    test('fails closed for invalid negative inventory values', () {
      expect(
        InventoryRules.validateQuantity(
          product: product(stock: -1),
          quantity: 1,
        ),
        isNotNull,
      );
    });
  });

  group('DeliveryEligibilityRules', () {
    test('allows regular delivery only when normalized countries match', () {
      final buyer = DetailedAddress(
        address: const Address(
          state: 'Gujarat',
          pincode: '380001',
          countryCode: 'IN',
        ),
      );
      final result = DeliveryEligibilityRules.evaluate(
        product: product(regular: true),
        quantity: 1,
        deliveryType: DeliveryType.regular,
        buyerAddress: buyer,
        sellerAddress: sellerAddress,
        sellerFastDeliveryEnabled: false,
      );
      expect(result.isEligible, isTrue);
    });

    test('rejects regular delivery when country is missing or mismatched', () {
      final missingCountry = DetailedAddress(
        address: const Address(state: 'Gujarat', pincode: '380001'),
      );
      final missingResult = DeliveryEligibilityRules.evaluate(
        product: product(regular: true),
        quantity: 1,
        deliveryType: DeliveryType.regular,
        buyerAddress: missingCountry,
        sellerAddress: sellerAddress,
        sellerFastDeliveryEnabled: false,
      );
      expect(
        missingResult.failure,
        DeliveryEligibilityFailure.countryCodeMissing,
      );

      final mismatchedCountry = DetailedAddress(
        address: const Address(
          state: 'Gujarat',
          pincode: '380001',
          countryCode: 'US',
        ),
      );
      final mismatchResult = DeliveryEligibilityRules.evaluate(
        product: product(regular: true),
        quantity: 1,
        deliveryType: DeliveryType.regular,
        buyerAddress: mismatchedCountry,
        sellerAddress: sellerAddress,
        sellerFastDeliveryEnabled: false,
      );
      expect(
        mismatchResult.failure,
        DeliveryEligibilityFailure.countryMismatch,
      );
    });

    test('requires seller opt-in and coordinates for fast delivery', () {
      final buyer = DetailedAddress(
        address: const Address(state: 'Gujarat', pincode: '380001'),
        location: const GeoLocation(latitude: 23.1, longitude: 72.6),
      );
      final result = DeliveryEligibilityRules.evaluate(
        product: product(fast: true),
        quantity: 1,
        deliveryType: DeliveryType.fast,
        buyerAddress: buyer,
        sellerAddress: sellerAddress,
        sellerFastDeliveryEnabled: true,
      );
      expect(result.isEligible, isTrue);
      expect(result.distanceKm, lessThan(60));

      final tooFar = DetailedAddress(
        address: const Address(state: 'Gujarat', pincode: '400001'),
        location: const GeoLocation(latitude: 19.076, longitude: 72.8777),
      );
      final tooFarResult = DeliveryEligibilityRules.evaluate(
        product: product(fast: true),
        quantity: 1,
        deliveryType: DeliveryType.fast,
        buyerAddress: tooFar,
        sellerAddress: sellerAddress,
        sellerFastDeliveryEnabled: true,
      );
      expect(
        tooFarResult.failure,
        DeliveryEligibilityFailure.fastDeliveryDistanceExceeded,
      );
    });

    test(
      'rejects every mode when product is inactive or stock is insufficient',
      () {
        final inactive = product(regular: true).copyWith(status: 'hidden');
        final result = DeliveryEligibilityRules.evaluate(
          product: inactive,
          quantity: 1,
          deliveryType: DeliveryType.regular,
          buyerAddress: sellerAddress,
          sellerAddress: sellerAddress,
          sellerFastDeliveryEnabled: true,
        );
        expect(result.failure, DeliveryEligibilityFailure.productNotActive);

        final outOfStock = product(regular: true, stock: 1);
        final stockResult = DeliveryEligibilityRules.evaluate(
          product: outOfStock,
          quantity: 2,
          deliveryType: DeliveryType.regular,
          buyerAddress: sellerAddress,
          sellerAddress: sellerAddress,
          sellerFastDeliveryEnabled: true,
        );
        expect(
          stockResult.failure,
          DeliveryEligibilityFailure.insufficientStock,
        );
      },
    );
  });
}
