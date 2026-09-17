import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../../data/seller_order_repository.dart';

part 'order_status_controller.g.dart';

@riverpod
class OrderStatusController extends _$OrderStatusController {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Updates the status of a specific order.
  Future<Result<void>> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    state = const AsyncLoading();
    
    final result = await ref.read(sellerOrderRepositoryProvider).updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
    );

    if (result.isSuccess) {
      state = const AsyncData(null);
    } else {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    }

    return result;
  }
}
