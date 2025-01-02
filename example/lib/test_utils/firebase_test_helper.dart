import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Helper class for Firebase test configuration and utilities.
class FirebaseTestHelper {
  /// The Firestore instance configured for testing.
  static late final FirebaseFirestore firestore;

  /// The collection name for tasks in tests.
  static const String tasksCollection = 'tasks';

  /// Initialize Firebase for testing.
  static Future<void> setupFirebaseForTesting() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        projectId: 'demo-local-dev',
        appId: '1:123456789012:web:123456789012',
        apiKey: 'mock-api-key',
        messagingSenderId: '123456789012',
      ),
    );

    // Configure Firestore to use the emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    firestore = FirebaseFirestore.instance;
  }

  /// Clean up test data in Firestore.
  static Future<void> cleanupTestData() async {
    final batch = firestore.batch();
    final snapshot = await firestore.collection(tasksCollection).get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Get a reference to the tasks collection.
  static CollectionReference<Map<String, dynamic>> getTasksCollection() {
    return firestore.collection(tasksCollection);
  }

  /// Get a document reference for a task.
  static DocumentReference<Map<String, dynamic>> getTaskDocument(String taskId) {
    return getTasksCollection().doc(taskId);
  }

  /// Create a unique collection name for isolation testing.
  static String createUniqueCollection([String prefix = 'test']) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Wait for a specific duration (useful for stream tests).
  static Future<void> wait([Duration duration = const Duration(seconds: 1)]) {
    return Future.delayed(duration);
  }

  /// Verify if a document exists.
  static Future<bool> documentExists(DocumentReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.get();
    return snapshot.exists;
  }

  /// Get the total number of documents in a collection.
  static Future<int> getCollectionCount(CollectionReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.count().get();
    return snapshot.count ?? 0;
  }

  /// Create a batch of test documents.
  static Future<List<DocumentReference>> createBatchDocuments({
    required CollectionReference<Map<String, dynamic>> collection,
    required List<Map<String, dynamic>> documents,
  }) async {
    final batch = firestore.batch();
    final refs = <DocumentReference>[];

    for (final doc in documents) {
      final ref = collection.doc();
      refs.add(ref);
      batch.set(ref, doc);
    }

    await batch.commit();
    return refs;
  }

  /// Listen to a document stream and collect events.
  static Stream<List<T>> collectStreamEvents<T>({
    required Stream<T> stream,
    Duration timeout = const Duration(seconds: 5),
  }) {
    final events = <T>[];
    return stream.transform<List<T>>(
      StreamTransformer<T, List<T>>.fromHandlers(
        handleData: (data, sink) {
          events.add(data);
          sink.add(List<T>.from(events));
        },
      ),
    ).timeout(timeout);
  }
}
