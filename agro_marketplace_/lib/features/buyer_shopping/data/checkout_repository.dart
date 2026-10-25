import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/commerce/checkout_pricing.dart';
import '../../../../core/commerce/commerce_rules.dart';
import '../../../../core/commerce/delivery_fee.dart';
import '../../../../core/commerce/product_listing_rules.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../../core/validation/delivery_address_validator.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../seller_inventory/domain/entities/product.dart';
import '../domain/entities/cart_item.dart';
import '../domain/entities/checkout_quote.dart';
import '../domain/entities/customer_order.dart';

part 'checkout_repository.g.dart';

/// Revalidates the buyer's cart and creates one parent order plus seller
/// packages using Firestore.
class CheckoutRepository {
  final FirebaseFirestore _firestore;

  CheckoutRepository(this._firestore);

  Future<Result<CheckoutQuote>> quoteOrder({
    required String buyerId,
    required ProductListingMode deliveryMode,
    required DetailedAddress buyerAddress,
  }) async {
    return Result.guard(
      () => _buildQuote(
        buyerId: buyerId,
        deliveryMode: deliveryMode,
        buyerAddress: buyerAddress,
      ),
    );
  }

  Future<Result<void>> placeOrder(
    CustomerOrder requestedOrder, {
    required ProductListingMode deliveryMode,
    required DetailedAddress buyerAddress,
  }) async {
    return Result.guard(() async {
      final customerOrderRef = _firestore
          .collection(FirestorePaths.customerOrders)
          .doc(requestedOrder.id);
      final validation = await _validateCheckout(
        buyerId: requestedOrder.buyerId,
        deliveryMode: deliveryMode,
        buyerAddress: buyerAddress,
      );
      final quote = validation.quote;
      final sellerItems = CheckoutPricing.groupBySeller(quote.items);
      final order = requestedOrder.copyWith(
        items: quote.items,
        totalAmount: quote.total,
        shippingAddress: buyerAddress.displayAddress,
        deliveryMode: deliveryMode.name,
        paymentStatus: 'pending',
        deliveryAddressSnapshot: buyerAddress.toMap(),
        deliveryEstimate: validation.deliveryEstimate,
      );
      final batch = _firestore.batch();
      final orderData = order.toJson()
        ..['items'] = quote.items.map((item) => item.toJson()).toList()
        ..['sellerIds'] = sellerItems.keys.toList()
        ..['subtotal'] = quote.subtotal
        ..['discount'] = quote.discount
        ..['tax'] = quote.tax
        ..['handlingFee'] = quote.handlingFee
        ..['deliveryFee'] = quote.deliveryFee;
      batch.set(customerOrderRef, orderData);
      for (final entry in sellerItems.entries) {
        final sellerOrderRef = _firestore
            .collection(FirestorePaths.sellerOrders)
            .doc();
        batch.set(sellerOrderRef, {
          'id': sellerOrderRef.id,
          'parentOrderId': order.id,
          'buyerId': order.buyerId,
          'sellerId': entry.key,
          'items': entry.value.map((item) => item.toJson()).toList(),
          'totalAmount': entry.value.fold<double>(
            0,
            (total, item) => total + item.totalPrice,
          ),
          'status': 'pending',
          'paymentStatus': 'pending',
          'shippingAddress': order.shippingAddress,
          'deliveryMode': order.deliveryMode,
          'deliveryAddressSnapshot': order.deliveryAddressSnapshot,
          'deliveryEstimate': validation.sellerEstimates[entry.key],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    });
  }

  Future<CheckoutQuote> _buildQuote({
    required String buyerId,
    required ProductListingMode deliveryMode,
    required DetailedAddress buyerAddress,
  }) async {
    final addressValidation = DeliveryAddressValidator.validate(buyerAddress);
    if (!addressValidation.isValid) {
      throw BusinessRuleException(
        message: 'The selected delivery address is invalid.',
      );
    }
    await _verifyOwnedAddress(buyerId, buyerAddress);

    final cartSnapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(buyerId)
        .collection('cartItems')
        .orderBy('addedAt', descending: true)
        .get();
    if (cartSnapshot.docs.isEmpty) {
      throw BusinessRuleException(
        message: 'Cannot place order with an empty cart.',
      );
    }

    final authoritativeItems = <CartItem>[];
    final sellerFees = <String, double>{};
    for (final cartDoc in cartSnapshot.docs) {
      final cartItem = CartItem.fromJson(cartDoc.data());
      final productSnapshot = await _firestore
          .collection(FirestorePaths.products)
          .doc(cartItem.productId)
          .get();
      if (!productSnapshot.exists || productSnapshot.data() == null) {
        throw BusinessRuleException(
          message: '${cartItem.name} is no longer available.',
        );
      }
      final product = Product.fromJson(productSnapshot.data()!);
      if (cartItem.sellerId != product.sellerId) {
        throw BusinessRuleException(
          message: '${cartItem.name} has an invalid seller assignment.',
        );
      }
      final inventoryFailure = InventoryRules.validateQuantity(
        product: product,
        quantity: cartItem.quantity,
      );
      if (inventoryFailure != null) {
        throw BusinessRuleException(
          message: '${product.name}: $inventoryFailure',
        );
      }
      final eligibility = ProductListingRules.evaluate(
        product: product,
        mode: deliveryMode,
        buyerAddress: buyerAddress,
      );
      if (!eligibility.isEligible) {
        throw BusinessRuleException(
          message:
              '${product.name}: ${eligibility.reason ?? 'Delivery unavailable.'}',
        );
      }
      authoritativeItems.add(
        cartItem.copyWith(
          sellerId: product.sellerId,
          name: product.name,
          price: product.price,
          unit: product.unit,
        ),
      );
      sellerFees[product.sellerId] = deliveryFeeForMode(
        product: product,
        mode: deliveryMode,
      );
    }
    final deliveryFee = sellerFees.values.fold<double>(
      0,
      (total, fee) => total + fee,
    );
    return CheckoutPricing.calculate(
      authoritativeItems,
      deliveryFee: deliveryFee,
    );
  }

  Future<_CheckoutValidation> _validateCheckout({
    required String buyerId,
    required ProductListingMode deliveryMode,
    required DetailedAddress buyerAddress,
  }) async {
    final quote = await _buildQuote(
      buyerId: buyerId,
      deliveryMode: deliveryMode,
      buyerAddress: buyerAddress,
    );
    final sellerEstimates = <String, String>{};
    for (final item in quote.items) {
      final snapshot = await _firestore
          .collection(FirestorePaths.products)
          .doc(item.productId)
          .get();
      final product = Product.fromJson(snapshot.data()!);
      final eligibility = ProductListingRules.evaluate(
        product: product,
        mode: deliveryMode,
        buyerAddress: buyerAddress,
      );
      if (eligibility.deliveryWindow != null) {
        sellerEstimates[item.sellerId] = eligibility.deliveryWindow!;
      }
    }
    final estimate = sellerEstimates.values.toSet().join(', ');
    return _CheckoutValidation(
      quote: quote,
      sellerEstimates: sellerEstimates,
      deliveryEstimate: estimate.isEmpty ? null : estimate,
    );
  }

  Future<void> _verifyOwnedAddress(
    String buyerId,
    DetailedAddress selectedAddress,
  ) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(buyerId)
        .get();
    final data = snapshot.data();
    final saved = data?['savedAddresses'];
    if (saved is! List) {
      throw BusinessRuleException(
        message: 'Select one of your saved addresses.',
      );
    }

    final belongsToBuyer = saved.any((value) {
      if (value is! Map) return false;
      try {
        return DetailedAddress.fromMap(Map<String, dynamic>.from(value)) ==
            selectedAddress;
      } catch (_) {
        return false;
      }
    });
    if (!belongsToBuyer) {
      throw BusinessRuleException(
        message: 'Select one of your saved addresses.',
      );
    }
  }
}

class _CheckoutValidation {
  final CheckoutQuote quote;
  final Map<String, String> sellerEstimates;
  final String? deliveryEstimate;

  const _CheckoutValidation({
    required this.quote,
    required this.sellerEstimates,
    required this.deliveryEstimate,
  });
}

@riverpod
CheckoutRepository checkoutRepository(Ref ref) {
  return CheckoutRepository(ref.watch(firebaseServiceProvider).firestore);
}
