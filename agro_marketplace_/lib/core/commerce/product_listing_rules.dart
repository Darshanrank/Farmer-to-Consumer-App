import '../../features/seller_inventory/domain/entities/product.dart';
import '../../shared/models/detailed_address.dart';
import 'commerce_rules.dart';

enum ProductListingMode { fast, regular }

class ProductListingEligibility {
  final bool isEligible;
  final String? reason;
  final double? distanceKm;
  final String? deliveryWindow;

  const ProductListingEligibility({
    required this.isEligible,
    this.reason,
    this.distanceKm,
    this.deliveryWindow,
  });
}

class ProductListingRules {
  const ProductListingRules._();

  static ProductListingEligibility evaluate({
    required Product product,
    required ProductListingMode mode,
    required DetailedAddress? buyerAddress,
  }) {
    if (!product.isAvailableForPurchase) {
      return const ProductListingEligibility(
        isEligible: false,
        reason: 'Product is out of stock.',
      );
    }

    if (mode == ProductListingMode.fast) {
      if (!product.supportsFastDelivery || !product.sellerManagedFastDelivery) {
        return const ProductListingEligibility(
          isEligible: false,
          reason: 'Seller does not offer seller-managed Fast Delivery.',
        );
      }
      if (buyerAddress?.location?.isValid != true) {
        return const ProductListingEligibility(
          isEligible: false,
          reason: 'Select a saved address with usable coordinates.',
        );
      }
      final sellerLocation = product.sellerServiceLocation;
      if (sellerLocation?.isValid != true) {
        return const ProductListingEligibility(
          isEligible: false,
          reason: 'Seller Fast Delivery location is not configured.',
        );
      }
      final minDays = product.fastDeliveryMinDays;
      final maxDays = product.fastDeliveryMaxDays;
      if (!_validWindow(minDays, maxDays, maximum: 7)) {
        return const ProductListingEligibility(
          isEligible: false,
          reason: 'Seller Fast Delivery window is not configured.',
        );
      }
      final distance = DeliveryEligibilityRules.distanceBetweenKm(
        buyerAddress!.location!,
        sellerLocation!,
      );
      if (distance > fastDeliveryRadiusKm) {
        return const ProductListingEligibility(
          isEligible: false,
          reason: 'Address is beyond the Fast Delivery service radius.',
        );
      }
      return ProductListingEligibility(
        isEligible: true,
        distanceKm: distance,
        deliveryWindow: '$minDays–$maxDays days',
      );
    }

    if (!product.supportsRegularDelivery) {
      return const ProductListingEligibility(
        isEligible: false,
        reason: 'Seller does not offer Regular Delivery.',
      );
    }
    final minDays = product.regularDeliveryMinDays;
    final maxDays = product.regularDeliveryMaxDays;
    if (!_validWindow(minDays, maxDays, maximum: 7)) {
      return const ProductListingEligibility(
        isEligible: false,
        reason: 'Seller Regular Delivery window is not configured.',
      );
    }
    return ProductListingEligibility(
      isEligible: true,
      deliveryWindow: '$minDays–$maxDays days',
    );
  }

  static bool _validWindow(int? min, int? max, {required int maximum}) =>
      min != null && max != null && min >= 1 && max >= min && max <= maximum;
}

class AddressCountry {
  const AddressCountry._();

  static String? normalized(String value) =>
      value.trim().toUpperCase().length == 2
      ? value.trim().toUpperCase()
      : null;
}
