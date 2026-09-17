import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../seller_orders/domain/entities/seller_order.dart';
import '../../data/buyer_order_repository.dart';

part 'buyer_orders_provider.g.dart';

/// Streams the order packages belonging to the currently authenticated buyer.
@riverpod
Stream<List<SellerOrder>> buyerOrders(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(buyerOrderRepositoryProvider).streamBuyerOrders(user.uid);
}
