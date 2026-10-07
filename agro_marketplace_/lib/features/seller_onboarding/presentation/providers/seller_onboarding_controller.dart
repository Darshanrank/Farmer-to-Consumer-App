import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/models/address.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../../shared/models/location.dart';
import '../../../auth/data/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'seller_onboarding_controller.g.dart';

@riverpod
class SellerOnboardingController extends _$SellerOnboardingController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<Result<void>> submitProfile({
    required String businessName,
    required String displayName,
    required String phone,
    required String line1,
    String? line2,
    String? landmark,
    String? village,
    String? taluka,
    String? district,
    required String stateValue,
    required String pincode,
    double? latitude,
    double? longitude,
    String? geohash,
  }) async {
    state = const AsyncLoading();

    final appUser = ref.read(appUserProvider).value;
    if (appUser == null) {
      final ex = Exception('User is not authenticated');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(AuthenticationException(message: 'User is not authenticated', originalError: ex));
    }

    // Build the structured DetailedAddress
    final address = Address(
      line1: line1,
      line2: line2,
      landmark: landmark,
      village: village,
      taluka: taluka,
      district: district,
      state: stateValue,
      pincode: pincode,
    );

    GeoLocation? location;
    if (latitude != null && longitude != null) {
      location = GeoLocation(
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
      );
    }

    final detailedAddress = DetailedAddress(
      address: address,
      location: location,
    );

    final updatedUser = appUser.copyWith(
      businessName: businessName,
      displayName: displayName,
      phone: phone,
      address: detailedAddress.toMap(),
    );

    final result = await ref.read(userRepositoryProvider).updateUser(updatedUser);
    
    if (result.isSuccess) {
      state = const AsyncData(null);
    } else {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    }
    
    return result;
  }
}
