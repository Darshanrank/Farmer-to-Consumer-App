/// Represents the current authentication state of the application.
enum AuthStatus {
  /// The app is starting and checking the authentication state.
  initial,

  /// The user is not authenticated.
  unauthenticated,

  /// An authentication operation is in progress (e.g. logging in).
  authenticating,

  /// The user is authenticated but has not verified their email.
  emailUnverified,

  /// The user is fully authenticated and verified.
  authenticated,
}
