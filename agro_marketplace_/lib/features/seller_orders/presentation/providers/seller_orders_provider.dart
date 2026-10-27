import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../domain/entities/seller_order.dart';
import '../../data/seller_order_repository.dart';

part 'seller_orders_provider.g.dart';

/// Streams the orders assigned to the currently authenticated seller.
@riverpod
Stream<List<SellerOrder>> sellerOrders(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref
      .watch(sellerOrderRepositoryProvider)
      .streamSellerOrders(user.uid)
      .asyncMap((orders) async {
        final repository = ref.read(notificationRepositoryProvider);
        for (final order in orders.where((order) => order.status == 'pending')) {
          try {
            await repository.createForUser(
              uid: user.uid,
              eventId: 'seller_new_order_${order.id}',
              title: 'New order received',
              message: 'A new order is waiting for your review.',
              type: 'new_order',
              entityId: order.id,
              entityType: 'sellerOrder',
            );
          } catch (error) {
            AppLogger.warning(
              'New seller order notification could not be saved.',
              context: 'SellerOrdersProvider',
              error: error,
              data: {'orderId': order.id},
            );
          }
        }
        return orders;
      });
}
