import 'package:flutter_test/flutter_test.dart';
import 'package:realty_app/models/property_filters.dart';

void main() {
  group('PropertyFilters Clear and Empty State Tests', () {
    test('Default PropertyFilters evaluates isEmpty as true', () {
      const filters = PropertyFilters();
      expect(filters.isEmpty, isTrue);
      expect(filters.activeLabels, isEmpty);
    });

    test('PropertyFilters with populated fields is not empty', () {
      const filters = PropertyFilters(
        purpose: 'Buy',
        category: 'Residential',
        type: 'Apartment',
      );
      expect(filters.isEmpty, isFalse);
      expect(filters.activeLabels, contains('Buy'));
      expect(filters.activeLabels, contains('Residential'));
      expect(filters.activeLabels, contains('Apartment'));
    });

    test('Cleared PropertyFilters with nulls produces empty activeLabels and isEmpty true', () {
      final filters = PropertyFilters(
        purpose: null,
        category: null,
        type: null,
        bedrooms: null,
        minPrice: null,
        maxPrice: null,
        status: null,
        constructionPhase: null,
        minArea: null,
        maxArea: null,
        bathrooms: null,
        parking: null,
        furnishing: null,
        amenities: null,
      );
      expect(filters.isEmpty, isTrue);
      expect(filters.activeLabels, isEmpty);
    });
  });
}
