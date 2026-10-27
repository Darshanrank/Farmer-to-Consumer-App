import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../seller_inventory/presentation/providers/inventory_providers.dart';
import '../../../seller_orders/domain/entities/seller_order.dart';
import '../../../seller_orders/presentation/providers/seller_orders_provider.dart';

class SellerSalesReportScreen extends ConsumerStatefulWidget {
  const SellerSalesReportScreen({super.key});

  @override
  ConsumerState<SellerSalesReportScreen> createState() =>
      _SellerSalesReportScreenState();
}

class _SellerSalesReportScreenState
    extends ConsumerState<SellerSalesReportScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(sellerOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sales report')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load sales: $error')),
        data: (items) {
          final filtered = items.where((order) {
            final date = order.createdAt;
            return date != null &&
                !date.isBefore(_range.start) &&
                date.isBefore(_range.end.add(const Duration(days: 1)));
          }).toList();
          final completed = filtered.where((order) => order.status == 'delivered');
          final gross = completed.fold<double>(
            0,
            (total, order) => total + order.totalAmount,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DateRangeButton(
                range: _range,
                onChanged: (range) => setState(() => _range = range),
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                orders: completed.length,
                gross: gross,
                note: 'Only delivered orders are included. Payment is pending in the current schema.',
              ),
              const SizedBox(height: 16),
              ..._productRows(completed),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _productRows(Iterable<SellerOrder> orders) {
    final quantities = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        quantities[item.name] = (quantities[item.name] ?? 0) + item.quantity;
      }
    }
    return quantities.entries
        .map((entry) => ListTile(
              title: Text(entry.key),
              trailing: Text('${entry.value} sold'),
            ))
        .toList();
  }
}

class SellerStockReportScreen extends ConsumerWidget {
  const SellerStockReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(sellerProductsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stock report')),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load stock: $error')),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = items[index];
            final available = product.availableQuantity;
            final opening = product.stockQuantity + product.soldQuantity;
            return Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(
                  'Opening (derived): $opening  •  Sold: ${product.soldQuantity}\n'
                  'Current available: $available  •  Reserved: ${product.reservedQuantity}',
                ),
                isThreeLine: true,
                trailing: product.stockQuantity < 5
                    ? const Icon(Icons.warning_amber, color: Colors.orange)
                    : const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  final DateTimeRange range;
  final ValueChanged<DateTimeRange> onChanged;

  const _DateRangeButton({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(
        '${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}',
      ),
      onPressed: () async {
        final selected = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: range,
        );
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int orders;
  final double gross;
  final String note;

  const _SummaryCard({
    required this.orders,
    required this.gross,
    required this.note,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$orders delivered orders',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Gross sales: ₹${gross.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(note, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}
