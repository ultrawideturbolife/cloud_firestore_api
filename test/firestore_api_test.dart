import 'package:cloud_firestore_api/abstracts/writeable.dart';
import 'package:cloud_firestore_api/api/firestore_api.dart';
import 'package:cloud_firestore_api/data/enums/search_term_type.dart';
import 'package:cloud_firestore_api/data/enums/timestamp_type.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_response/turbo_response.dart';

void main() {
  late FirestoreApi<TestDTO> api;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    api = FirestoreApi<TestDTO>(
      collectionPath: () => 'test_collection',
      firebaseFirestore: firestore,
      fromJson: TestDTO.fromJson,
      toJson: (dto) => dto.toJson(),
    );
  });

  group('FirestoreApi', () {
    group('CRUD Operations', () {
      test('createDoc - should create document successfully', () async {
        // Arrange
        final dto = TestDTO(name: 'Test', value: 42);

        // Act
        final response = await api.createDoc(writeable: dto);

        // Assert
        expect(response.isSuccess, true);
        final doc = await firestore.collection('test_collection').get();
        expect(doc.docs.length, 1);
        expect(doc.docs.first.data()['name'], 'Test');
        expect(doc.docs.first.data()['value'], 42);
      });

      test('createDoc - should fail with invalid data', () async {
        // Arrange
        final dto = TestDTO(name: '', value: -1); // Invalid data

        // Act
        final response = await api.createDoc(writeable: dto);

        // Assert
        expect(response.isSuccess, false);
        final doc = await firestore.collection('test_collection').get();
        expect(doc.docs.length, 0);
      });

      test('findById - should find document by id', () async {
        // Arrange
        final dto = TestDTO(name: 'Test', value: 42);
        final docRef = await firestore.collection('test_collection').add(dto.toJson());

        // Act
        final response = await api.findByIdWithConverter(id: docRef.id);

        // Assert
        expect(response.isSuccess, true);
        expect(response.result?.name, 'Test');
        expect(response.result?.value, 42);
      });

      test('findAll - should return all documents', () async {
        // Arrange
        await firestore.collection('test_collection').add(
              TestDTO(name: 'Test 1', value: 1).toJson(),
            );
        await firestore.collection('test_collection').add(
              TestDTO(name: 'Test 2', value: 2).toJson(),
            );

        // Act
        final response = await api.findAllWithConverter();

        // Assert
        expect(response.isSuccess, true);
        expect(response.result?.length, 2);
      });

      test('updateDoc - should update document successfully', () async {
        // Arrange
        final dto = TestDTO(name: 'Test', value: 42);
        final docRef = await firestore.collection('test_collection').add(dto.toJson());
        final updateDto = TestDTO(name: 'Updated', value: 100);

        // Act
        final response = await api.updateDoc(
          writeable: updateDto,
          id: docRef.id,
        );

        // Assert
        expect(response.isSuccess, true);
        final updatedDoc = await firestore.collection('test_collection').doc(docRef.id).get();
        expect(updatedDoc.data()?['name'], 'Updated');
        expect(updatedDoc.data()?['value'], 100);
      });

      test('deleteDoc - should delete document successfully', () async {
        // Arrange
        final dto = TestDTO(name: 'Test', value: 42);
        final docRef = await firestore.collection('test_collection').add(dto.toJson());

        // Act
        final response = await api.deleteDoc(id: docRef.id);

        // Assert
        expect(response.isSuccess, true);
        final doc = await firestore.collection('test_collection').doc(docRef.id).get();
        expect(doc.exists, false);
      });
    });

    group('Search Operations', () {
      test('findBySearchTerm - should find documents by search term', () async {
        // Arrange
        await firestore.collection('test_collection').add(
              TestDTO(name: 'Apple', value: 1).toJson(),
            );
        await firestore.collection('test_collection').add(
              TestDTO(name: 'Application', value: 2).toJson(),
            );

        // Act
        final response = await api.findBySearchTermWithConverter(
          searchTerm: 'App',
          searchField: 'name',
          searchTermType: SearchTermType.startsWith,
        );

        // Assert
        expect(response.isSuccess, true);
        expect(response.result?.length, 2);
        expect(response.result?.first.name, 'Apple');
        expect(response.result?[1].name, 'Application');
      });

      test('should find documents by search term', () async {
        // Create test documents
        await firestore.collection('test_collection').add({
          'name': 'Test Item 1',
          'value': 42,
        });
        await firestore.collection('test_collection').add({
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
    });

    group('Batch Operations', () {
      test('batchCreateDoc - should create multiple documents in batch', () async {
        // Arrange
        final batch = firestore.batch();
        final dto1 = TestDTO(name: 'Batch 1', value: 1);
        final dto2 = TestDTO(name: 'Batch 2', value: 2);

        // Act
        final response1 = await api.batchCreateDoc(writeable: dto1, writeBatch: batch);
        final response2 = await api.batchCreateDoc(writeable: dto2, writeBatch: batch);
        await batch.commit();

        // Assert
        expect(response1.isSuccess, true);
        expect(response2.isSuccess, true);
        final docs = await firestore.collection('test_collection').get();
        expect(docs.docs.length, 2);
      });
    });

    group('Timestamp Handling', () {
      test('createDoc - should add timestamps when specified', () async {
        // Arrange
        final dto = TestDTO(name: 'Test', value: 42);

        // Act
        final response = await api.createDoc(
          writeable: dto,
          createTimeStampType: TimestampType.createdAndUpdated,
        );

        // Assert
        expect(response.isSuccess, true);
        final doc = await firestore.collection('test_collection').get();
        expect(doc.docs.first.data()['created'], isNotNull);
        expect(doc.docs.first.data()['updated'], isNotNull);
      });
    });
  });
}

class TestDTO extends Writeable {
  TestDTO({
    required this.name,
    required this.value,
  });

  final String name;
  final int value;

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

  factory TestDTO.fromJson(Map<String, dynamic> json) => TestDTO(
        name: json['name'] as String,
        value: json['value'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}
