import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/app_notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  Stream<List<AppNotification>> streamForUser(String uid) => _collection(uid)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map(AppNotification.fromSnapshot).toList());

  Future<void> markRead(String uid, String notificationId) =>
      _collection(uid).doc(notificationId).update({'isRead': true});

  Future<void> markAllRead(String uid, Iterable<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.update(_collection(uid).doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> createForUser({
    required String uid,
    required String eventId,
    required String title,
    required String message,
    required String type,
    String? entityId,
    String? entityType,
  }) {
    final data = <String, Object?>{
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (entityId != null) data['entityId'] = entityId;
    if (entityType != null) data['entityType'] = entityType;
    return _collection(uid).doc(eventId).set(data);
  }
}
