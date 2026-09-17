/// User roles in the application.
///
/// Mapped to Firebase custom claims and used in authorization checks.
enum UserRole {
  buyer('buyer'),
  seller('seller'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) => switch (value) {
    'buyer' => UserRole.buyer,
    'seller' => UserRole.seller,
    'admin' => UserRole.admin,
    _ => UserRole.buyer,
  };
}
