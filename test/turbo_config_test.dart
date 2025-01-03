import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore_api/data/models/turbo_config.dart';

void main() {
  group('TurboConfig', () {
    late TurboConfig config;

    setUp(() {
      config = const TurboConfig();
    });

    group('default values', () {
      test('should have default create messages', () {
        expect(config.effectiveCreateSuccessTitle, 'Create success');
        expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
        expect(config.effectiveCreateFailedTitle, 'Create failed');
        expect(config.effectiveCreateFailedSingularMessage,
            'Unable to create item, please try again later.');
      });

      test('should have default search messages', () {
        expect(config.effectiveSearchSuccessTitle, 'Search success');
        expect(config.effectiveSearchSuccessSingularMessage, 'item was found.');
        expect(config.effectiveSearchFailedTitle, 'Search failed');
        expect(config.effectiveSearchFailedSingularMessage,
            'Unable to find item, please try again later.');
      });

      test('should have default update messages', () {
        expect(config.effectiveUpdateSuccessTitle, 'Update success');
        expect(config.effectiveUpdateSuccessSingularMessage, 'item has been updated.');
        expect(config.effectiveUpdateFailedTitle, 'Update failed');
        expect(config.effectiveUpdateFailedSingularMessage,
            'Unable to update item, please try again later.');
      });

      test('should have default delete messages', () {
        expect(config.effectiveDeleteSuccessTitle, 'Delete success');
        expect(config.effectiveDeleteSuccessSingularMessage, 'item has been deleted.');
        expect(config.effectiveDeleteFailedTitle, 'Delete failed');
        expect(config.effectiveDeleteFailedSingularMessage,
            'Unable to delete item, please try again later.');
      });
    });

    group('custom values', () {
      setUp(() {
        config = const TurboConfig(
          singularForm: 'product',
          pluralForm: 'products',
          createSuccessTitle: 'Created',
          createSuccessSingularMessage: 'Product has been created.',
          createSuccessPluralMessage: 'Products have been created.',
          createFailedTitle: 'Create Error',
          createFailedSingularMessage: 'Unable to create product.',
          createFailedPluralMessage: 'Unable to create products.',
          searchSuccessTitle: 'Found',
          searchSuccessSingularMessage: 'Product was found.',
          searchSuccessPluralMessage: 'Products were found.',
          searchFailedTitle: 'Search Error',
          searchFailedSingularMessage: 'Unable to find product.',
          searchFailedPluralMessage: 'Unable to find products.',
          updateSuccessTitle: 'Updated',
          updateSuccessSingularMessage: 'Product has been updated.',
          updateSuccessPluralMessage: 'Products have been updated.',
          updateFailedTitle: 'Update Error',
          updateFailedSingularMessage: 'Unable to update product.',
          updateFailedPluralMessage: 'Unable to update products.',
          deleteSuccessTitle: 'Deleted',
          deleteSuccessSingularMessage: 'Product has been deleted.',
          deleteSuccessPluralMessage: 'Products have been deleted.',
          deleteFailedTitle: 'Delete Error',
          deleteFailedSingularMessage: 'Unable to delete product.',
          deleteFailedPluralMessage: 'Unable to delete products.',
        );
      });

      test('should use custom create messages', () {
        expect(config.effectiveCreateSuccessTitle, 'Created');
        expect(config.effectiveCreateSuccessSingularMessage, 'Product has been created.');
        expect(config.effectiveCreateSuccessPluralMessage, 'Products have been created.');
        expect(config.effectiveCreateFailedTitle, 'Create Error');
        expect(config.effectiveCreateFailedSingularMessage, 'Unable to create product.');
        expect(config.effectiveCreateFailedPluralMessage, 'Unable to create products.');
      });

      test('should use custom search messages', () {
        expect(config.effectiveSearchSuccessTitle, 'Found');
        expect(config.effectiveSearchSuccessSingularMessage, 'Product was found.');
        expect(config.effectiveSearchSuccessPluralMessage, 'Products were found.');
        expect(config.effectiveSearchFailedTitle, 'Search Error');
        expect(config.effectiveSearchFailedSingularMessage, 'Unable to find product.');
        expect(config.effectiveSearchFailedPluralMessage, 'Unable to find products.');
      });

      test('should use custom update messages', () {
        expect(config.effectiveUpdateSuccessTitle, 'Updated');
        expect(config.effectiveUpdateSuccessSingularMessage, 'Product has been updated.');
        expect(config.effectiveUpdateSuccessPluralMessage, 'Products have been updated.');
        expect(config.effectiveUpdateFailedTitle, 'Update Error');
        expect(config.effectiveUpdateFailedSingularMessage, 'Unable to update product.');
        expect(config.effectiveUpdateFailedPluralMessage, 'Unable to update products.');
      });

      test('should use custom delete messages', () {
        expect(config.effectiveDeleteSuccessTitle, 'Deleted');
        expect(config.effectiveDeleteSuccessSingularMessage, 'Product has been deleted.');
        expect(config.effectiveDeleteSuccessPluralMessage, 'Products have been deleted.');
        expect(config.effectiveDeleteFailedTitle, 'Delete Error');
        expect(config.effectiveDeleteFailedSingularMessage, 'Unable to delete product.');
        expect(config.effectiveDeleteFailedPluralMessage, 'Unable to delete products.');
      });
    });

    group('pluralization', () {
      test('should handle default plural messages', () {
        expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
        expect(config.effectiveCreateSuccessPluralMessage, 'items have been created.');
        expect(config.effectiveSearchSuccessSingularMessage, 'item was found.');
        expect(config.effectiveSearchSuccessPluralMessage, 'items were found.');
      });

      test('should handle custom plural messages', () {
        final config = const TurboConfig(
          singularForm: 'record',
          pluralForm: 'records',
        );

        expect(config.effectiveCreateSuccessSingularMessage, 'record has been created.');
        expect(config.effectiveCreateSuccessPluralMessage, 'records have been created.');
        expect(config.effectiveSearchSuccessSingularMessage, 'record was found.');
        expect(config.effectiveSearchSuccessPluralMessage, 'records were found.');
      });
    });

    group('error handling', () {
      test('should handle empty singular/plural forms', () {
        const config = TurboConfig(
          singularForm: '',
          pluralForm: '',
        );

        expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
        expect(config.effectiveCreateSuccessPluralMessage, 'items have been created.');
      });

      test('should handle null singular/plural forms', () {
        const config = TurboConfig();

        expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
        expect(config.effectiveCreateSuccessPluralMessage, 'items have been created.');
      });
    });
  });
}
