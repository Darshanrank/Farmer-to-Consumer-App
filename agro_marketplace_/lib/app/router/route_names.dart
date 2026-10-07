/// Named route constants for the application.
///
/// Every route reference must use these constants to prevent typos.
class RouteNames {
  const RouteNames._();

  // === Auth ===
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String emailVerification = 'emailVerification';
  static const String forgotPassword = 'forgotPassword';

  // === Seller ===
  static const String sellerDashboard = 'sellerDashboard';
  static const String sellerOnboarding = 'sellerOnboarding';
  static const String sellerProfile = 'sellerProfile';
  static const String sellerEditProfile = 'sellerEditProfile';
  static const String sellerBusinessProfile = 'sellerBusinessProfile';
  static const String sellerStore = 'sellerStore';
  static const String sellerDelivery = 'sellerDelivery';
  static const String sellerProducts = 'sellerProducts';
  static const String sellerAddProduct = 'sellerAddProduct';
  static const String sellerEditProduct = 'sellerEditProduct';
  static const String sellerInventory = 'sellerInventory';
  static const String sellerOrders = 'sellerOrders';
  static const String sellerOrderDetail = 'sellerOrderDetail';
  static const String sellerDiscounts = 'sellerDiscounts';
  static const String sellerSettings = 'sellerSettings';
  static const String sellerHelp = 'sellerHelp';

  // === Buyer (future) ===
  static const String buyerHome = 'buyerHome';
  static const String buyerProductDetail = 'buyerProductDetail';
  static const String buyerCart = 'buyerCart';
  static const String buyerCheckout = 'buyerCheckout';
  static const String buyerOrders = 'buyerOrders';
  static const String buyerOrderDetail = 'buyerOrderDetail';
  static const String buyerSearch = 'buyerSearch';
  static const String buyerProfile = 'buyerProfile';
  static const String editProfile = 'editProfile';
}
