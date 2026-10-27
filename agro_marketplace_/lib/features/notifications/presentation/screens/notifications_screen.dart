import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authUserProvider).value?.uid;
    final notifications = ref.watch(userNotificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: uid == null
                ? null
                : () async {
                    final items = notifications.value ?? const [];
                    await ref
                        .read(notificationRepositoryProvider)
                        .markAllRead(uid, items.where((item) => !item.isRead).map((item) => item.id));
                  },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load notifications: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('You have no notifications.'))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    tileColor: item.isRead ? null : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .25),
                    leading: Icon(item.isRead ? Icons.notifications_none : Icons.notifications_active),
                    title: Text(item.title),
                    subtitle: Text('${item.message}\n${item.createdAt}'),
                    isThreeLine: true,
                    onTap: !item.isRead && uid != null
                        ? () => ref.read(notificationRepositoryProvider).markRead(uid, item.id)
                        : null,
                  );
                },
              )),
    );
  }
}
