import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/kos_load_result.dart';
import '../data/kos_repository.dart';
import '../models/kos.dart';

class KosDetailProvider extends ChangeNotifier {
  KosDetailProvider(this._repository, this.kosId) {
    load();
  }

  final KosRepository _repository;
  final String kosId;
  StreamSubscription<KosLoadResult<Kos>>? _subscription;

  KosLoadResult<Kos> _state = const KosLoadResult<Kos>.loading();

  KosLoadResult<Kos> get state => _state;

  void load() {
    _subscription?.cancel();
    _subscription = _repository.fetchDetail(kosId).listen((state) {
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
