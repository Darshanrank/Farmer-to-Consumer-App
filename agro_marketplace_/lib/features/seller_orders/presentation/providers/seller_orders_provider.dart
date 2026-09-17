import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
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
  return ref.watch(sellerOrderRepositoryProvider).streamSellerOrders(user.uid);
}
