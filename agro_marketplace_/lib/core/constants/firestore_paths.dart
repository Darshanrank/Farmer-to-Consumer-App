/// Firestore collection and document path constants.
///
/// Centralizes all Firestore paths to prevent typos and ensure consistency.
/// Every Firestore access in the app must use these constants.
class FirestorePaths {
  const FirestorePaths._();

  // === Collections ===
  static const String users = 'users';
  static const String sellerProfiles = 'sellerProfiles';
  static const String sellerBusinessProfiles = 'sellerBusinessProfiles';
  static const String sellerStores = 'sellerStores';
  static const String sellerDeliveryProfiles = 'sellerDeliveryProfiles';
  static const String sellerDeliveryZones = 'sellerDeliveryZones';
  static const String categories = 'categories';
  static const String brands = 'brands';
  static const String products = 'products';
  static const String sellerListings = 'sellerListings';
  static const String inventory = 'inventory';
  static const String inventoryTransactions = 'inventoryTransactions';
  static const String customerOrders = 'customerOrders';
  static const String sellerOrders = 'sellerOrders';
  static const String discounts = 'discounts';
  static const String notifications = 'notifications';
  static const String auditLogs = 'auditLogs';

  // === Document paths ===
  static String userDoc(String userId) => '$users/$userId';
  static String sellerProfileDoc(String sellerId) => '$sellerProfiles/$sellerId';
  static String sellerBusinessDoc(String sellerId) => '$sellerBusinessProfiles/$sellerId';
  static String sellerStoreDoc(String storeId) => '$sellerStores/$storeId';
  static String sellerDeliveryProfileDoc(String sellerId) => '$sellerDeliveryProfiles/$sellerId';
  static String categoryDoc(String categoryId) => '$categories/$categoryId';
  static String brandDoc(String brandId) => '$brands/$brandId';
  static String productDoc(String productId) => '$products/$productId';
  static String sellerListingDoc(String listingId) => '$sellerListings/$listingId';
  static String inventoryDoc(String inventoryId) => '$inventory/$inventoryId';
  static String customerOrderDoc(String orderId) => '$customerOrders/$orderId';
  static String sellerOrderDoc(String sellerOrderId) => '$sellerOrders/$sellerOrderId';
  static String discountDoc(String discountId) => '$discounts/$discountId';
  static String notificationDoc(String notificationId) => '$notifications/$notificationId';

  // === Subcollections ===
  static String sellerOrdersSubcollection(String orderId) =>
      '$customerOrders/$orderId/sellerOrders';
  static String orderItemsSubcollection(String sellerOrderId) =>
      '$sellerOrders/$sellerOrderId/items';
}
