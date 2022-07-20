import 'package:cloud_firestore/cloud_firestore.dart';

/// Used to pass around [WriteBatch] instances accompanied with the last [DocumentReference].
class WriteBatchWithReference<T> {
  const WriteBatchWithReference({
    required this.writeBatch,
    required this.documentReference,
  });

  /// The writeBatch that was just used.
  final WriteBatch writeBatch;

  /// The reference that was just used.
  final DocumentReference<T> documentReference;
}
