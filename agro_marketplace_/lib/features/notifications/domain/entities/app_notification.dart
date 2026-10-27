import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String? entityId;
  final String? entityType;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.entityId,
    this.entityType,
  });

  factory AppNotification.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final timestamp = data['createdAt'];
    return AppNotification(
      id: snapshot.id,
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      entityId: data['entityId'] as String?,
      entityType: data['entityType'] as String?,
    );
  }
}
