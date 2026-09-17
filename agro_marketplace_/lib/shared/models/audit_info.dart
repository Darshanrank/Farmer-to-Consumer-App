import 'package:cloud_firestore/cloud_firestore.dart';

/// Audit metadata attached to important entities.
///
/// Tracks who created/updated a document and when.
class AuditInfo {
  final String? createdBy;
  final DateTime? createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  const AuditInfo({
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory AuditInfo.fromMap(Map<String, dynamic> map) {
    return AuditInfo(
      createdBy: map['createdBy'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedBy: map['updatedBy'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Map for creating a new document (sets createdAt).
  Map<String, dynamic> toCreateMap(String userId) {
    return {
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Map for updating a document (only sets updatedAt).
  static Map<String, dynamic> toUpdateMap(String userId) {
    return {
      'updatedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
