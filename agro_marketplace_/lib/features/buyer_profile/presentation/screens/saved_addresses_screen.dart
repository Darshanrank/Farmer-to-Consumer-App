import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../auth/data/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<Map<String, dynamic>> addresses,
  ) async {
    final user = ref.read(appUserProvider).value;
    if (user == null) return;
    final updated = List<Map<String, dynamic>>.from(addresses)..removeAt(index);
    final result = await ref
        .read(userRepositoryProvider)
        .updateUser(user.copyWith(savedAddresses: updated));
    if (context.mounted && result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.exceptionOrNull?.message ?? 'Could not delete address',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).value;
    final addresses = user?.savedAddresses ?? const <Map<String, dynamic>>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            tooltip: 'Add address',
            onPressed: () => context.pushNamed(RouteNames.addSavedAddress),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(RouteNames.addSavedAddress),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add delivery address'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = DetailedAddress.fromMap(addresses[index]);
                return Card(
                  child: ListTile(
                    title: Text(address.recipientName ?? 'Delivery address'),
                    subtitle: Text(address.displayAddress),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.pushNamed(
                            RouteNames.editSavedAddress,
                            pathParameters: {'index': '$index'},
                          );
                        } else {
                          _delete(context, ref, index, addresses);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
