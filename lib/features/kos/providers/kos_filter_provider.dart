import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/kos_filters.dart';
import '../data/kos_load_result.dart';
import '../data/kos_repository.dart';
import '../models/kos.dart';

class KosFilterProvider extends ChangeNotifier {
  KosFilterProvider(this._repository) {
    load();
  }

  final KosRepository _repository;
  StreamSubscription<KosLoadResult<List<Kos>>>? _subscription;

  KosFilters _filters = const KosFilters();
  KosLoadResult<List<Kos>> _state = const KosLoadResult<List<Kos>>.loading();

  KosFilters get filters => _filters;
  KosLoadResult<List<Kos>> get state => _state;

  void setArea(String? area) {
    _filters = _filters.copyWith(area: area);
  }

  void setPriceRange(int? minPrice, int? maxPrice) {
    _filters = _filters.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void setFacilities(List<String> facilities) {
    _filters = _filters.copyWith(facilities: facilities);
  }

  void clear() {
    _filters = _filters.clear();
    load();
  }

  void apply() {
    load();
  }

  void load() {
    _subscription?.cancel();
    _subscription = _repository.fetchList(_filters).listen((state) {
      _state = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
