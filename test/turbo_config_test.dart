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
        expect(config.createSuccessTitle, 'Create success');
        expect(config.createSuccessSingularMessage, 'Item has been created.');
        expect(config.createFailedTitle, 'Create failed');
        expect(
            config.createFailedSingularMessage, 'Unable to create item, please try again later.');
      });

      test('should have default search messages', () {
        expect(config.searchSuccessTitle, 'Search success');
        expect(config.searchSuccessSingularMessage, 'Item was found.');
        expect(config.searchFailedTitle, 'Search failed');
        expect(config.searchFailedSingularMessage, 'Unable to find item, please try again later.');
      });

      test('should have default update messages', () {
        expect(config.updateSuccessTitle, 'Update success');
        expect(config.updateSuccessSingularMessage, 'Item has been updated.');
        expect(config.updateFailedTitle, 'Update failed');
        expect(
            config.updateFailedSingularMessage, 'Unable to update item, please try again later.');
      });

      test('should have default delete messages', () {
        expect(config.deleteSuccessTitle, 'Delete success');
        expect(config.deleteSuccessSingularMessage, 'Item has been deleted.');
        expect(config.deleteFailedTitle, 'Delete failed');
        expect(
            config.deleteFailedSingularMessage, 'Unable to delete item, please try again later.');
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
        expect(config.createSuccessTitle, 'Created');
        expect(config.createSuccessSingularMessage, 'Product has been created.');
        expect(config.createSuccessPluralMessage, 'Products have been created.');
        expect(config.createFailedTitle, 'Create Error');
        expect(config.createFailedSingularMessage, 'Unable to create product.');
        expect(config.createFailedPluralMessage, 'Unable to create products.');
      });

      test('should use custom search messages', () {
        expect(config.searchSuccessTitle, 'Found');
        expect(config.searchSuccessSingularMessage, 'Product was found.');
        expect(config.searchSuccessPluralMessage, 'Products were found.');
        expect(config.searchFailedTitle, 'Search Error');
        expect(config.searchFailedSingularMessage, 'Unable to find product.');
        expect(config.searchFailedPluralMessage, 'Unable to find products.');
      });

      test('should use custom update messages', () {
        expect(config.updateSuccessTitle, 'Updated');
        expect(config.updateSuccessSingularMessage, 'Product has been updated.');
        expect(config.updateSuccessPluralMessage, 'Products have been updated.');
        expect(config.updateFailedTitle, 'Update Error');
        expect(config.updateFailedSingularMessage, 'Unable to update product.');
        expect(config.updateFailedPluralMessage, 'Unable to update products.');
      });

      test('should use custom delete messages', () {
        expect(config.deleteSuccessTitle, 'Deleted');
        expect(config.deleteSuccessSingularMessage, 'Product has been deleted.');
        expect(config.deleteSuccessPluralMessage, 'Products have been deleted.');
        expect(config.deleteFailedTitle, 'Delete Error');
        expect(config.deleteFailedSingularMessage, 'Unable to delete product.');
        expect(config.deleteFailedPluralMessage, 'Unable to delete products.');
      });
    });

    group('pluralization', () {
      test('should handle default plural messages', () {
        expect(config.createSuccessSingularMessage, 'Item has been created.');
        expect(config.createSuccessPluralMessage, 'Items have been created.');
        expect(config.searchSuccessSingularMessage, 'Item was found.');
        expect(config.searchSuccessPluralMessage, 'Items were found.');
      });

      test('should handle custom plural messages', () {
        final config = const TurboConfig(
          singularForm: 'record',
          pluralForm: 'records',
        );

        expect(config.createSuccessSingularMessage, 'Record has been created.');
        expect(config.createSuccessPluralMessage, 'Records have been created.');
        expect(config.searchSuccessSingularMessage, 'Record was found.');
        expect(config.searchSuccessPluralMessage, 'Records were found.');
      });
    });

    group('error handling', () {
      test('should handle empty singular/plural forms', () {
        const config = TurboConfig(
          singularForm: '',
          pluralForm: '',
        );

        expect(config.createSuccessSingularMessage, 'Item has been created.');
        expect(config.createSuccessPluralMessage, 'Items have been created.');
      });

      test('should handle null singular/plural forms', () {
        const config = TurboConfig();

        expect(config.createSuccessSingularMessage, 'Item has been created.');
        expect(config.createSuccessPluralMessage, 'Items have been created.');
      });
    });
  });
}
