import 'package:cloud_firestore_api/data/models/turbo_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TurboConfig', () {
    test('should use default values when not provided', () {
      const config = TurboConfig();
      expect(config.effectiveCreateSuccessTitle, 'Create success');
      expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
      expect(config.effectiveCreateSuccessPluralMessage, 'items have been created.');
    });

    test('should use custom values when provided', () {
      const config = TurboConfig(
        singularForm: 'user',
        pluralForm: 'users',
        createSuccessTitle: 'Custom success',
        createSuccessSingularMessage: 'Custom user created',
        createSuccessPluralMessage: 'Custom users created',
      );
      expect(config.effectiveCreateSuccessTitle, 'Custom success');
      expect(config.effectiveCreateSuccessSingularMessage, 'Custom user created');
      expect(config.effectiveCreateSuccessPluralMessage, 'Custom users created');
    });

    test('should handle empty singular/plural forms', () {
      const config = TurboConfig(
        singularForm: '',
        pluralForm: '',
      );
      expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
      expect(config.effectiveCreateSuccessPluralMessage, 'items have been created.');
    });

    test('should handle custom singular form with default plural form', () {
      const config = TurboConfig(
        singularForm: 'book',
      );
      expect(config.effectiveCreateSuccessSingularMessage, 'book has been created.');
      expect(config.effectiveCreateSuccessPluralMessage, 'items have been created.');
    });

    test('should handle custom plural form with default singular form', () {
      const config = TurboConfig(
        pluralForm: 'books',
      );
      expect(config.effectiveCreateSuccessSingularMessage, 'item has been created.');
      expect(config.effectiveCreateSuccessPluralMessage, 'books have been created.');
    });

    test('should handle all CRUD operations with custom forms', () {
      const config = TurboConfig(
        singularForm: 'product',
        pluralForm: 'products',
      );

      // Create
      expect(config.effectiveCreateSuccessSingularMessage, 'product has been created.');
      expect(config.effectiveCreateSuccessPluralMessage, 'products have been created.');
      expect(config.effectiveCreateFailedSingularMessage,
          'Unable to create product, please try again later.');
      expect(config.effectiveCreateFailedPluralMessage,
          'Unable to create products, please try again later.');

      // Read/Search
      expect(config.effectiveSearchSuccessSingularMessage, 'product was found.');
      expect(config.effectiveSearchSuccessPluralMessage, 'products were found.');
      expect(config.effectiveSearchFailedSingularMessage,
          'Unable to find product, please try again later.');
      expect(config.effectiveSearchFailedPluralMessage,
          'Unable to find products, please try again later.');

      // Update
      expect(config.effectiveUpdateSuccessSingularMessage, 'product has been updated.');
      expect(config.effectiveUpdateSuccessPluralMessage, 'products have been updated.');
      expect(config.effectiveUpdateFailedSingularMessage,
          'Unable to update product, please try again later.');
      expect(config.effectiveUpdateFailedPluralMessage,
          'Unable to update products, please try again later.');

      // Delete
      expect(config.effectiveDeleteSuccessSingularMessage, 'product has been deleted.');
      expect(config.effectiveDeleteSuccessPluralMessage, 'products have been deleted.');
      expect(config.effectiveDeleteFailedSingularMessage,
          'Unable to delete product, please try again later.');
      expect(config.effectiveDeleteFailedPluralMessage,
          'Unable to delete products, please try again later.');
    });
  });
}
