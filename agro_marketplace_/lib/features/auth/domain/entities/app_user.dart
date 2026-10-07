import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Converts the `address` field between Firestore (which may store a legacy
/// plain [String]) and the app (which expects [Map<String, dynamic>?]).
class AddressJsonConverter
    implements JsonConverter<Map<String, dynamic>?, Object?> {
  const AddressJsonConverter();

  @override
  Map<String, dynamic>? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) return json;
    // Legacy string → wrap into a structured map with line1
    if (json is String) {
      return {'line1': json, 'state': '', 'pincode': ''};
    }
    return null;
  }

  @override
  Object? toJson(Map<String, dynamic>? object) => object;
}

/// Represents a user in the application, mirroring the Firestore `users` document.
@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String uid,
    required String email,
    @Default('buyer') String role,
    @Default(false) bool isEmailVerified,
    String? displayName,
    String? phone,
    String? photoUrl,
    String? businessName,
    /// Structured address stored as a map (see [DetailedAddress]).
    /// Backward compatible: old plain-string values are auto-converted via [AddressJsonConverter].
    @AddressJsonConverter() Map<String, dynamic>? address,
    @Default('active') String status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _AppUser;

  bool get isSeller => role == 'seller';
  bool get isBuyer => role == 'buyer';

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

