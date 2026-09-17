/// Delivery type for orders and seller configuration.
enum DeliveryType {
  instant('instant', 'Instant Delivery'),
  regular('regular', 'Regular Delivery');

  final String value;
  final String displayName;
  const DeliveryType(this.value, this.displayName);

  static DeliveryType fromString(String value) =>
      DeliveryType.values.firstWhere(
        (d) => d.value == value,
        orElse: () => DeliveryType.regular,
      );
}

/// Seller type classification.
enum SellerType {
  individual('individual', 'Individual Farmer'),
  shop('shop', 'Agricultural Shop'),
  retailer('retailer', 'Retailer'),
  wholesaler('wholesaler', 'Wholesaler'),
  distributor('distributor', 'Distributor');

  final String value;
  final String displayName;
  const SellerType(this.value, this.displayName);

  static SellerType fromString(String value) =>
      SellerType.values.firstWhere(
        (s) => s.value == value,
        orElse: () => SellerType.individual,
      );
}

/// Listing status for seller product listings.
enum ListingStatus {
  draft('draft', 'Draft'),
  pendingReview('pending_review', 'Pending Review'),
  active('active', 'Active'),
  inactive('inactive', 'Inactive'),
  rejected('rejected', 'Rejected'),
  suspended('suspended', 'Suspended');

  final String value;
  final String displayName;
  const ListingStatus(this.value, this.displayName);

  static ListingStatus fromString(String value) =>
      ListingStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => ListingStatus.draft,
      );
}

/// Inventory transaction types.
enum InventoryTransactionType {
  opening('opening', 'Opening Stock'),
  purchase('purchase', 'Purchase'),
  sale('sale', 'Sale'),
  saleReturn('sale_return', 'Sale Return'),
  adjustment('adjustment', 'Manual Adjustment'),
  damage('damage', 'Damage'),
  expired('expired', 'Expired'),
  reservation('reservation', 'Reservation'),
  release('release', 'Reservation Release');

  final String value;
  final String displayName;
  const InventoryTransactionType(this.value, this.displayName);

  static InventoryTransactionType fromString(String value) =>
      InventoryTransactionType.values.firstWhere(
        (t) => t.value == value,
        orElse: () => InventoryTransactionType.adjustment,
      );
}

/// Delivery zone types.
enum DeliveryZoneType {
  radius('radius', 'Radius'),
  pincode('pincode', 'Pincode'),
  village('village', 'Village'),
  taluka('taluka', 'Taluka'),
  district('district', 'District'),
  state('state', 'State');

  final String value;
  final String displayName;
  const DeliveryZoneType(this.value, this.displayName);

  static DeliveryZoneType fromString(String value) =>
      DeliveryZoneType.values.firstWhere(
        (z) => z.value == value,
        orElse: () => DeliveryZoneType.radius,
      );
}
