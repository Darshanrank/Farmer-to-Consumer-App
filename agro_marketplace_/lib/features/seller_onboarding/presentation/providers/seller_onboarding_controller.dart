import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
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
    required String address,
  }) async {
    state = const AsyncLoading();

    final appUser = ref.read(appUserProvider).value;
    if (appUser == null) {
      final ex = Exception('User is not authenticated');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(AuthenticationException(message: 'User is not authenticated', originalError: ex));
    }

    final updatedUser = appUser.copyWith(
      businessName: businessName,
      displayName: displayName,
      phone: phone,
      address: address,
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
