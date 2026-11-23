import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/features/kos/data/kos_filters.dart';

void main() {
  test('empty filters do not restrict results', () {
    const filters = KosFilters();

    expect(filters.isEmpty, isTrue);
    expect(filters.normalizedArea, isNull);
    expect(filters.normalizedFacilities, isEmpty);
  });

  test('area filter is normalized', () {
    const filters = KosFilters(area: '  Singaraja  ');

    expect(filters.normalizedArea, 'Singaraja');
  });

  test('price range is valid when minimum and maximum are nonnegative', () {
    const filters = KosFilters(minPrice: 500000, maxPrice: 1000000);

    expect(filters.isValid, isTrue);
  });

  test('price range rejects negative or reversed values', () {
    const negative = KosFilters(minPrice: -1);
    const reversed = KosFilters(minPrice: 1000000, maxPrice: 500000);

    expect(negative.isValid, isFalse);
    expect(reversed.isValid, isFalse);
  });

  test('facility filter removes blank and duplicate values', () {
    const filters = KosFilters(facilities: ['AC', ' ', 'AC', 'WiFi']);

    expect(filters.normalizedFacilities, ['AC', 'WiFi']);
  });

  test('combined filters keep every selected criterion', () {
    const filters = KosFilters(
      area: 'Singaraja',
      minPrice: 500000,
      maxPrice: 1000000,
      facilities: ['AC', 'WiFi'],
    );

    expect(filters.normalizedArea, 'Singaraja');
    expect(filters.minPrice, 500000);
    expect(filters.maxPrice, 1000000);
    expect(filters.normalizedFacilities, ['AC', 'WiFi']);
  });
}
