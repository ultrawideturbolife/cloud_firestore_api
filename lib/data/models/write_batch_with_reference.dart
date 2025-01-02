import 'package:cloud_firestore/cloud_firestore.dart';

/// Used to pass around [WriteBatch] instances accompanied with the last [DocumentReference].
///
/// The type parameter [T] represents the type of data that can be written to or read from
/// the document reference. This ensures type-safety when working with batched operations.
class WriteBatchWithReference<T> {
  /// Creates a new [WriteBatchWithReference] instance.
  ///
  /// The [writeBatch] is the Firestore batch operation that was used.
  /// The [documentReference] is the reference to the last document that was operated on.
  const WriteBatchWithReference({
    required this.writeBatch,
    required this.documentReference,
  });

  /// The writeBatch that was just used.
  ///
  /// This batch can be used for further operations or committed to apply all
  /// batched changes to Firestore.
  final WriteBatch writeBatch;

  /// The reference that was just used.
  ///
  /// This reference points to the last document that was operated on in the batch.
  /// It is typed with [T] to ensure type-safety when reading or writing data.
  final DocumentReference<T> documentReference;

  /// Creates a new [WriteBatchWithReference] with a different type parameter.
  ///
  /// This is useful when you need to change the type of the document reference
  /// while keeping the same batch operation.
  WriteBatchWithReference<R> cast<R>() {
    return WriteBatchWithReference<R>(
      writeBatch: writeBatch,
      documentReference: documentReference.withConverter(
        fromFirestore: (snapshot, _) => throw UnimplementedError(),
        toFirestore: (_, __) => throw UnimplementedError(),
      ),
    );
  }
}
