import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts between [DocumentReference] and [String] for JSON serialization.
class DocumentReferenceConverter implements JsonConverter<DocumentReference?, String?> {
  const DocumentReferenceConverter();

  @override
  DocumentReference? fromJson(String? path) {
    if (path == null) return null;
    return FirebaseFirestore.instance.doc(path);
  }

  @override
  String? toJson(DocumentReference? ref) => ref?.path;
}
