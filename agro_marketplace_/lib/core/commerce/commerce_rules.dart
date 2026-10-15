import 'dart:math' as math;

import '../enums/delivery_type.dart';
import '../../features/seller_inventory/domain/entities/product.dart';
import '../../shared/models/detailed_address.dart';
import '../../shared/models/location.dart';

const double fastDeliveryRadiusKm = 60;
const int regularDeliveryTargetMinDays = 1;
const int regularDeliveryTargetMaxDays = 7;

enum DeliveryEligibilityFailure {
  productNotActive,
  insufficientStock,
  fastDeliveryNotEnabled,
  fastDeliveryNotSupported,
  buyerCoordinatesMissing,
  sellerCoordinatesMissing,
  fastDeliveryDistanceExceeded,
  countryCodeMissing,
  countryMismatch,
  regularDeliveryNotSupported,
}

class DeliveryEligibilityResult {
  final DeliveryEligibilityFailure? failure;
  final double? distanceKm;

  const DeliveryEligibilityResult._({this.failure, this.distanceKm});

  const DeliveryEligibilityResult.eligible({double? distanceKm})
    : this._(distanceKm: distanceKm);

  const DeliveryEligibilityResult.ineligible(DeliveryEligibilityFailure failure)
    : this._(failure: failure);

  bool get isEligible => failure == null;
}

/// Pure domain rules for delivery-mode eligibility.
class DeliveryEligibilityRules {
  const DeliveryEligibilityRules._();

  static DeliveryEligibilityResult evaluate({
    required Product product,
    required int quantity,
    required DeliveryType deliveryType,
    required DetailedAddress buyerAddress,
    required DetailedAddress sellerAddress,
    required bool sellerFastDeliveryEnabled,
  }) {
    if (product.status != 'active') {
      return const DeliveryEligibilityResult.ineligible(
        DeliveryEligibilityFailure.productNotActive,
      );
    }
    final inventoryFailure = InventoryRules.validateQuantity(
      product: product,
      quantity: quantity,
    );
    if (inventoryFailure != null) {
      return const DeliveryEligibilityResult.ineligible(
        DeliveryEligibilityFailure.insufficientStock,
      );
    }

    switch (deliveryType) {
      case DeliveryType.regular:
        return _evaluateRegular(
          product: product,
          buyerAddress: buyerAddress,
          sellerAddress: sellerAddress,
        );
      case DeliveryType.fast:
        if (!product.supportsFastDelivery) {
          return const DeliveryEligibilityResult.ineligible(
            DeliveryEligibilityFailure.fastDeliveryNotSupported,
          );
        }
        if (!sellerFastDeliveryEnabled) {
          return const DeliveryEligibilityResult.ineligible(
            DeliveryEligibilityFailure.fastDeliveryNotEnabled,
          );
        }
        final buyerLocation = buyerAddress.location;
        final sellerLocation = sellerAddress.location;
        if (buyerLocation == null || !buyerLocation.isValid) {
          return const DeliveryEligibilityResult.ineligible(
            DeliveryEligibilityFailure.buyerCoordinatesMissing,
          );
        }
        if (sellerLocation == null || !sellerLocation.isValid) {
          return const DeliveryEligibilityResult.ineligible(
            DeliveryEligibilityFailure.sellerCoordinatesMissing,
          );
        }
        final distanceKm = distanceBetweenKm(buyerLocation, sellerLocation);
        if (distanceKm > fastDeliveryRadiusKm) {
          return const DeliveryEligibilityResult.ineligible(
            DeliveryEligibilityFailure.fastDeliveryDistanceExceeded,
          );
        }
        return DeliveryEligibilityResult.eligible(distanceKm: distanceKm);
    }
  }

  static DeliveryEligibilityResult _evaluateRegular({
    required Product product,
    required DetailedAddress buyerAddress,
    required DetailedAddress sellerAddress,
  }) {
    if (!product.supportsRegularDelivery) {
      return const DeliveryEligibilityResult.ineligible(
        DeliveryEligibilityFailure.regularDeliveryNotSupported,
      );
    }
    final buyerCountry = buyerAddress.address.normalizedCountryCode;
    final sellerCountry = sellerAddress.address.normalizedCountryCode;
    if (buyerCountry == null || sellerCountry == null) {
      return const DeliveryEligibilityResult.ineligible(
        DeliveryEligibilityFailure.countryCodeMissing,
      );
    }
    if (buyerCountry != sellerCountry) {
      return const DeliveryEligibilityResult.ineligible(
        DeliveryEligibilityFailure.countryMismatch,
      );
    }
    return const DeliveryEligibilityResult.eligible();
  }

  static double distanceBetweenKm(GeoLocation first, GeoLocation second) {
    const earthRadiusKm = 6371.0088;
    final latitudeDelta = _toRadians(second.latitude - first.latitude);
    final longitudeDelta = _toRadians(second.longitude - first.longitude);
    final firstLatitude = _toRadians(first.latitude);
    final secondLatitude = _toRadians(second.latitude);
    final a =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(firstLatitude) *
            math.cos(secondLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    final centralAngle =
        2 * math.atan2(math.sqrt(a.toDouble()), math.sqrt(1 - a.toDouble()));
    return earthRadiusKm * centralAngle;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

class InventoryRules {
  const InventoryRules._();

  static String? validateQuantity({
    required Product product,
    required int quantity,
  }) {
    if (quantity <= 0) return 'Quantity must be greater than zero.';
    if (product.status != 'active') return 'Product is not available.';
    if (product.stockQuantity < 0 ||
        product.reservedQuantity < 0 ||
        product.soldQuantity < 0) {
      return 'Inventory quantities cannot be negative.';
    }
    if (quantity < product.minOrderQuantity) {
      return 'Quantity is below the minimum order quantity.';
    }
    if (product.availableQuantity < quantity) {
      return 'Insufficient available inventory.';
    }
    return null;
  }

  static String? validateProductForSale(Product product) {
    if (product.stockQuantity < 0 ||
        product.reservedQuantity < 0 ||
        product.soldQuantity < 0) {
      return 'Product inventory is invalid or unavailable.';
    }
    if (product.minOrderQuantity <= 0) {
      return 'Product minimum order quantity is invalid.';
    }
    if (product.status != 'active') return 'Product is not available.';
    if (product.availableQuantity <= 0) {
      return 'Product is out of stock.';
    }
    return null;
  }
}
