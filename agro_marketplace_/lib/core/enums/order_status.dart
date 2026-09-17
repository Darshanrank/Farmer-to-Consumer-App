/// Order status for customer orders.
enum OrderStatus {
  placed('placed', 'Placed'),
  processing('processing', 'Processing'),
  partiallyFulfilled('partially_fulfilled', 'Partially Fulfilled'),
  fulfilled('fulfilled', 'Fulfilled'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled'),
  returned('returned', 'Returned');

  final String value;
  final String displayName;
  const OrderStatus(this.value, this.displayName);

  static OrderStatus fromString(String value) =>
      OrderStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => OrderStatus.placed,
      );
}

/// Seller-specific order fulfillment status.
enum SellerOrderStatus {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected'),
  preparing('preparing', 'Preparing'),
  packed('packed', 'Packed'),
  ready('ready', 'Ready for Delivery'),
  dispatched('dispatched', 'Dispatched'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled');

  final String value;
  final String displayName;
  const SellerOrderStatus(this.value, this.displayName);

  static SellerOrderStatus fromString(String value) =>
      SellerOrderStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => SellerOrderStatus.pending,
      );

  /// Whether this status allows the seller to act on the order.
  bool get isActionable => switch (this) {
    SellerOrderStatus.pending ||
    SellerOrderStatus.accepted ||
    SellerOrderStatus.preparing ||
    SellerOrderStatus.packed ||
    SellerOrderStatus.ready => true,
    _ => false,
  };
}

/// Payment status for orders.
enum PaymentStatus {
  pending('pending', 'Pending'),
  paid('paid', 'Paid'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded');

  final String value;
  final String displayName;
  const PaymentStatus(this.value, this.displayName);

  static PaymentStatus fromString(String value) =>
      PaymentStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => PaymentStatus.pending,
      );
}
