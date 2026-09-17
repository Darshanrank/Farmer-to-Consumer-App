/// Seller lifecycle status.
///
/// Controls what actions a seller can perform and what UI they see.
/// Status transitions are enforced by Cloud Functions.
enum SellerStatus {
  draft('draft', 'Draft'),
  emailUnverified('email_unverified', 'Email Not Verified'),
  profileIncomplete('profile_incomplete', 'Profile Incomplete'),
  verificationPending('verification_pending', 'Verification Pending'),
  verified('verified', 'Verified'),
  active('active', 'Active'),
  rejected('rejected', 'Rejected'),
  suspended('suspended', 'Suspended'),
  deactivated('deactivated', 'Deactivated');

  final String value;
  final String displayName;
  const SellerStatus(this.value, this.displayName);

  static SellerStatus fromString(String value) =>
      SellerStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => SellerStatus.draft,
      );

  /// Whether the seller can manage products and receive orders.
  bool get canOperate => this == SellerStatus.active;

  /// Whether the seller profile can be edited.
  bool get canEditProfile => this != SellerStatus.suspended;

  /// Whether the seller is in the onboarding process.
  bool get isOnboarding => switch (this) {
    SellerStatus.draft ||
    SellerStatus.emailUnverified ||
    SellerStatus.profileIncomplete => true,
    _ => false,
  };
}
