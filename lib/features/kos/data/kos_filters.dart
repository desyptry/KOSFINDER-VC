class KosFilters {
  const KosFilters({
    this.area,
    this.minPrice,
    this.maxPrice,
    this.facilities = const [],
  });

  final String? area;
  final int? minPrice;
  final int? maxPrice;
  final List<String> facilities;

  bool get isEmpty =>
      (area == null || area!.trim().isEmpty) &&
      minPrice == null &&
      maxPrice == null &&
      facilities.isEmpty;

  bool get isValid =>
      (minPrice == null || minPrice! >= 0) &&
      (maxPrice == null || maxPrice! >= 0) &&
      (minPrice == null || maxPrice == null || minPrice! <= maxPrice!);

  String? get normalizedArea {
    final value = area?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  List<String> get normalizedFacilities {
    final unique = <String>{};
    for (final facility in facilities) {
      final value = facility.trim();
      if (value.isNotEmpty) {
        unique.add(value);
      }
    }
    return unique.toList(growable: false);
  }

  KosFilters copyWith({
    Object? area = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    Object? facilities = _unset,
  }) {
    return KosFilters(
      area: identical(area, _unset) ? this.area : area as String?,
      minPrice: identical(minPrice, _unset) ? this.minPrice : minPrice as int?,
      maxPrice: identical(maxPrice, _unset) ? this.maxPrice : maxPrice as int?,
      facilities: identical(facilities, _unset)
          ? this.facilities
          : facilities as List<String>,
    );
  }

  KosFilters clear() {
    return const KosFilters();
  }
}

const _unset = Object();
