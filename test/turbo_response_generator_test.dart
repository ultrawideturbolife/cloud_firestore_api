import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore_api/data/models/turbo_config.dart';
import 'package:cloud_firestore_api/util/turbo_response_generator.dart';
import 'package:turbo_response/turbo_response.dart';

void main() {
  group('TurboResponseGenerator', () {
    late TurboConfig config;
    late TurboResponseGenerator generator;

    setUp(() {
      config = const TurboConfig(
        singularForm: 'product',
        pluralForm: 'products',
      );
      generator = TurboResponseGenerator(config: config);
    });

    group('create responses', () {
      test('should generate success response with result', () {
        final result = {'id': '123', 'name': 'Test Product'};
        final response = generator.createSuccessResponse<Map<String, dynamic>>(
          isPlural: false,
          result: result,
        );

        expect(response, isA<TurboResponse<Map<String, dynamic>>>());
        expect(response.title, equals('Create success'));
        expect(response.message, equals('product has been created.'));

        if (response case Success(:final result)) {
          expect(result, equals(result));
        } else {
          fail('Should be success');
        }
      });

      test('should generate failed response with error', () {
        final error = Exception('Test error');
        final response = generator.createFailedResponse<void>(
          isPlural: false,
          error: error,
        );

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Create failed'));
        expect(response.message, equals('Unable to create product, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, equals(error));
        } else {
          fail('Should be failure');
        }
      });

      test('should generate failed response without error', () {
        final response = generator.createFailedResponse<void>(isPlural: false);

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Create failed'));
        expect(response.message, equals('Unable to create product, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, isA<Exception>());
        } else {
          fail('Should be failure');
        }
      });
    });

    group('search responses', () {
      test('should generate success response with single result', () {
        final result = {'id': '123', 'name': 'Test Product'};
        final response = generator.searchSuccessResponse<Map<String, dynamic>>(
          isPlural: false,
          result: result,
        );

        expect(response, isA<TurboResponse<Map<String, dynamic>>>());
        expect(response.title, equals('Search success'));
        expect(response.message, equals('product was found.'));

        if (response case Success(:final result)) {
          expect(result, equals(result));
        } else {
          fail('Should be success');
        }
      });

      test('should generate success response with multiple results', () {
        final results = [
          {'id': '123', 'name': 'Test Product 1'},
          {'id': '456', 'name': 'Test Product 2'},
        ];
        final response = generator.searchSuccessResponse<List<Map<String, dynamic>>>(
          isPlural: true,
          result: results,
        );

        expect(response, isA<TurboResponse<List<Map<String, dynamic>>>>());
        expect(response.title, equals('Search success'));
        expect(response.message, equals('products were found.'));

        if (response case Success(:final result)) {
          expect(result, equals(results));
        } else {
          fail('Should be success');
        }
      });

      test('should generate failed response for single item', () {
        final error = Exception('Test error');
        final response = generator.searchFailedResponse<void>(
          isPlural: false,
          error: error,
        );

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Search failed'));
        expect(response.message, equals('Unable to find product, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, equals(error));
        } else {
          fail('Should be failure');
        }
      });

      test('should generate failed response for multiple items', () {
        final response = generator.searchFailedResponse<void>(isPlural: true);

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Search failed'));
        expect(response.message, equals('Unable to find products, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, isA<Exception>());
        } else {
          fail('Should be failure');
        }
      });
    });

    group('update responses', () {
      test('should generate success response with result', () {
        final result = {'id': '123', 'name': 'Updated Product'};
        final response = generator.updateSuccessResponse<Map<String, dynamic>>(
          isPlural: false,
          result: result,
        );

        expect(response, isA<TurboResponse<Map<String, dynamic>>>());
        expect(response.title, equals('Update success'));
        expect(response.message, equals('product has been updated.'));

        if (response case Success(:final result)) {
          expect(result, equals(result));
        } else {
          fail('Should be success');
        }
      });

      test('should generate failed response with error', () {
        final error = Exception('Test error');
        final response = generator.updateFailedResponse<void>(
          isPlural: false,
          error: error,
        );

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Update failed'));
        expect(response.message, equals('Unable to update product, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, equals(error));
        } else {
          fail('Should be failure');
        }
      });
    });

    group('delete responses', () {
      test('should generate success response', () {
        final response = generator.deleteSuccessResponse(isPlural: false);

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Delete success'));
        expect(response.message, equals('product has been deleted.'));

        if (response case Success()) {
          expect(true, isTrue); // Success with void result
        } else {
          fail('Should be success');
        }
      });

      test('should generate failed response with error', () {
        final error = Exception('Test error');
        final response = generator.deleteFailedResponse<void>(
          isPlural: false,
          error: error,
        );

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Delete failed'));
        expect(response.message, equals('Unable to delete product, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, equals(error));
        } else {
          fail('Should be failure');
        }
      });

      test('should generate failed response for multiple items', () {
        final response = generator.deleteFailedResponse<void>(isPlural: true);

        expect(response, isA<TurboResponse<void>>());
        expect(response.title, equals('Delete failed'));
        expect(response.message, equals('Unable to delete products, please try again later.'));

        if (response case Fail(:final error)) {
          expect(error, isA<Exception>());
        } else {
          fail('Should be failure');
        }
      });
    });

    group('empty responses', () {
      test('should generate empty success response', () {
        final response = generator.emptySuccessResponse();

        expect(response, isA<TurboResponse<void>>());
        if (response case Success()) {
          expect(true, isTrue); // Success with void result
        } else {
          fail('Should be success');
        }
      });

      test('should generate empty fail response', () {
        final error = Exception('Test error');
        final response = generator.emptyFailResponse(error: error);

        expect(response, isA<TurboResponse<void>>());
        if (response case Fail(:final error)) {
          expect(error, equals(error));
        } else {
          fail('Should be failure');
        }
      });
    });
  });
}
