/// Firebase Storage path constants.
///
/// Organized by entity type with seller ownership scoping.
/// Every storage upload/download must use these path builders.
class StoragePaths {
  const StoragePaths._();

  // === Profile images ===
  static String userProfileImage(String userId) =>
      'users/$userId/profile/avatar.jpg';

  // === Seller store images ===
  static String storeImage(String sellerId, String fileName) =>
      'sellers/$sellerId/store/$fileName';

  // === Product images ===
  static String productImage(String sellerId, String listingId, String fileName) =>
      'sellers/$sellerId/products/$listingId/$fileName';

  // === Business documents (sensitive — restricted access) ===
  static String businessDocument(String sellerId, String documentType, String fileName) =>
      'sellers/$sellerId/documents/$documentType/$fileName';

  // === Verification documents ===
  static String verificationDocument(String sellerId, String fileName) =>
      'sellers/$sellerId/verification/$fileName';

  // === Category images (admin) ===
  static String categoryImage(String categoryId, String fileName) =>
      'categories/$categoryId/$fileName';

  // === Brand logos (admin) ===
  static String brandLogo(String brandId, String fileName) =>
      'brands/$brandId/$fileName';
}
