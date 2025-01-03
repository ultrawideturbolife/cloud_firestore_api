import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/abstracts/writeable.dart';
import 'package:cloud_firestore_api/api/firestore_api.dart';
import 'package:cloud_firestore_api/data/enums/search_term_type.dart';
import 'package:cloud_firestore_api/data/models/turbo_config.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_response/turbo_response.dart';

void main() {
  group('FirestoreApi', () {
    late FakeFirebaseFirestore firestore;
    late TestFirestoreApi api;
    const collectionPath = 'test_collection';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      api = TestFirestoreApi(
        firebaseFirestore: firestore,
        collectionPath: () => collectionPath,
      );
    });

    test('should create a document successfully', () async {
      final request = TestRequest(
        name: 'Test Item',
        value: 42,
      );

      final response = await api.createDoc(writeable: request);

      if (response case Success(:final result)) {
        final doc = await result.get();
        final data = doc.data() as Map<String, dynamic>;
        expect(doc.exists, true);
        expect(data['name'], 'Test Item');
        expect(data['value'], 42);
      } else {
        fail('Document creation failed');
      }
    });

    test('should find documents by search term', () async {
      // Create test documents
      await firestore.collection(collectionPath).add({
        'name': 'Test Item 1',
        'value': 42,
      });
      await firestore.collection(collectionPath).add({
        'name': 'Test Item 2',
        'value': 43,
      });

      final response = await api.findBySearchTerm(
        searchTerm: 'Test',
        searchField: 'name',
        searchTermType: SearchTermType.startsWith,
      );

      if (response case Success(:final result)) {
        expect(result.length, 2);
        expect(result[0]['name'], 'Test Item 1');
        expect(result[1]['name'], 'Test Item 2');
      } else {
        fail('Search failed');
      }
    });

    test('should update a document successfully', () async {
      // Create a test document
      final docRef = await firestore.collection(collectionPath).add({
        'name': 'Test Item',
        'value': 42,
      });

      final request = TestRequest(
        name: 'Updated Item',
        value: 43,
      );

      final response = await api.updateDoc(
        id: docRef.id,
        writeable: request,
      );

      if (response case Success(:final result)) {
        final doc = await result.get();
        final data = doc.data() as Map<String, dynamic>;
        expect(doc.exists, true);
        expect(data['name'], 'Updated Item');
        expect(data['value'], 43);
      } else {
        fail('Document update failed');
      }
    });

    test('should delete a document successfully', () async {
      // Create a test document
      final docRef = await firestore.collection(collectionPath).add({
        'name': 'Test Item',
        'value': 42,
      });

      final response = await api.deleteDoc(id: docRef.id);

      if (response case Success()) {
        final doc = await docRef.get();
        expect(doc.exists, false);
      } else {
        fail('Document deletion failed');
      }
    });
  });
}

class TestRequest implements Writeable {
  const TestRequest({
    required this.name,
    required this.value,
  });

  final String name;
  final int value;

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };

  @override
  TurboResponse<void> isValidResponse() {
    if (name.isEmpty) {
      return TurboResponse.fail(
        error: Exception('Name cannot be empty'),
        title: 'Validation Error',
        message: 'The name field must not be empty',
      );
    }
    if (value < 0) {
      return TurboResponse.fail(
        error: Exception('Value must be positive'),
        title: 'Validation Error',
        message: 'The value must be greater than or equal to 0',
      );
    }
    return TurboResponse.emptySuccess();
  }
}

class TestFirestoreApi extends FirestoreApi {
  TestFirestoreApi({
    required super.firebaseFirestore,
    required super.collectionPath,
  });
}
