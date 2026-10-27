import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/notification_repository.dart';
import '../../domain/entities/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(firebaseServiceProvider).firestore);
});

final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(authUserProvider).value?.uid;
  if (uid == null) return const Stream<List<AppNotification>>.empty();
  return ref.watch(notificationRepositoryProvider).streamForUser(uid);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref
          .watch(userNotificationsProvider)
          .value
          ?.where((notification) => !notification.isRead)
          .length ??
      0;
});

final notificationsFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => ref.watch(firebaseServiceProvider).firestore,
);
