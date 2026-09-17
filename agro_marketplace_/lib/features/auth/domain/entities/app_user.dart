import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Represents a user in the application, mirroring the Firestore `users` document.
@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String uid,
    required String email,
    @Default('seller') String role,
    @Default(false) bool isEmailVerified,
    String? displayName,
    String? phone,
    String? photoUrl,
    String? businessName,
    String? address,
    @Default('active') String status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
