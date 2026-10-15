import '../constants/app_constants.dart';
import '../../features/seller_inventory/domain/entities/product.dart';
import 'product_listing_rules.dart';

double deliveryFeeForMode({
  required Product product,
  required ProductListingMode mode,
}) {
  final configuredFee = mode == ProductListingMode.fast
      ? product.fastDeliveryFee
      : product.regularDeliveryFee;

  if (configuredFee != null && configuredFee.isFinite && configuredFee >= 0) {
    return configuredFee;
  }
  return AppConstants.deliveryFee;
}
