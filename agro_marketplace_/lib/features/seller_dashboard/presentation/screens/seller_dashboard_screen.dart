import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/seller_dashboard_provider.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).value;
    final metrics = ref.watch(sellerDashboardMetricsProvider);
    final recent = ref.watch(recentOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              user?.displayName ?? 'Seller',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
            const SizedBox(height: 24),
            // Warning banner if profile incomplete
            if (user != null && (user.displayName == null || user.phone == null || user.businessName == null))
              InkWell(
                onTap: () {
                  context.pushNamed(RouteNames.sellerOnboarding); // In the future, push to Edit Profile
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete your profile',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add your business details to start selling.',
                              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'Today\'s Sales',
                  value: '₹${metrics.todaysSales.toStringAsFixed(0)}',
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                ),
                _MetricCard(
                  title: 'Pending Orders',
                  value: '${metrics.pendingOrders}',
                  icon: Icons.pending_actions,
                  color: Colors.blue,
                ),
                _MetricCard(
                  title: 'Active Products',
                  value: '${metrics.activeProducts}',
                  icon: Icons.inventory_2,
                  color: Colors.orange,
                ),
                _MetricCard(
                  title: 'Low Stock',
                  value: '${metrics.lowStockProducts}',
                  icon: Icons.warning_rounded,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No recent orders', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                itemBuilder: (context, index) {
                  final order = recent[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Order #${order.id.substring(0, 8)}'),
                      subtitle: Text(
                        order.createdAt != null ? DateFormat.yMMMd().format(order.createdAt!) : '',
                      ),
                      trailing: Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      onTap: () {
                        context.pushNamed(RouteNames.sellerOrderDetail, pathParameters: {'id': order.id});
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final MaterialColor color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.shade300, color.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              if (title == 'Pending Orders' && int.tryParse(value) != null && int.parse(value) > 0)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.red.shade100,
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: const Text('Action Required', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                 )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
