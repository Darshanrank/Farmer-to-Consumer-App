import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../seller_orders/presentation/providers/seller_orders_provider.dart';
import '../../../seller_inventory/presentation/providers/inventory_providers.dart';
import '../../../seller_orders/domain/entities/seller_order.dart';

part 'seller_dashboard_provider.g.dart';

class DashboardMetrics {
  final double todaysSales;
  final int pendingOrders;
  final int activeProducts;
  final int lowStockProducts;

  DashboardMetrics({
    this.todaysSales = 0.0,
    this.pendingOrders = 0,
    this.activeProducts = 0,
    this.lowStockProducts = 0,
  });
}

@riverpod
DashboardMetrics sellerDashboardMetrics(Ref ref) {
  final products = ref.watch(sellerProductsProvider).value ?? [];
  final orders = ref.watch(sellerOrdersProvider).value ?? [];

  final now = DateTime.now();
  
  double sales = 0;
  int pending = 0;
  
  for (var order in orders) {
    if (order.status == 'pending') pending++;
    if (order.status == 'delivered' && order.createdAt != null) {
      if (order.createdAt!.year == now.year && 
          order.createdAt!.month == now.month && 
          order.createdAt!.day == now.day) {
        sales += order.totalAmount;
      }
    }
  }

  int active = 0;
  int lowStock = 0;
  
  for (var product in products) {
    if (product.status == 'active') active++;
    if (product.stockQuantity < 5) lowStock++;
  }

  return DashboardMetrics(
    todaysSales: sales,
    pendingOrders: pending,
    activeProducts: active,
    lowStockProducts: lowStock,
  );
}

@riverpod
List<SellerOrder> recentOrders(Ref ref) {
  final orders = ref.watch(sellerOrdersProvider).value ?? [];
  if (orders.isEmpty) return [];
  
  // Sort by date descending (should already be sorted from provider, but just in case)
  final sorted = List<SellerOrder>.from(orders)
    ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    
  return sorted.take(3).toList();
}
