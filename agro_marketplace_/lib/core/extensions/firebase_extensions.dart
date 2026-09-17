import 'package:cloud_firestore/cloud_firestore.dart';

/// Extensions on Firestore [DocumentSnapshot] for safer data access.
extension DocumentSnapshotExtensions on DocumentSnapshot<Map<String, dynamic>> {
  /// Returns the data map, throwing if the document doesn't exist.
  Map<String, dynamic> get dataOrThrow {
    final data = this.data();
    if (data == null) {
      throw StateError('Document $id does not exist');
    }
    return data;
  }
}

/// Extensions on Firestore [QuerySnapshot] for convenience.
extension QuerySnapshotExtensions on QuerySnapshot<Map<String, dynamic>> {
  /// Whether the query returned any results.
  bool get isEmpty => docs.isEmpty;

  /// Whether the query returned results.
  bool get isNotEmpty => docs.isNotEmpty;
}
