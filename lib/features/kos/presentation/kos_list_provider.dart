import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/kos_load_result.dart';
import '../data/kos_repository.dart';
import '../models/kos.dart';

class KosListProvider extends ChangeNotifier {
  KosListProvider(this._repository) {
    load();
  }

  final KosRepository _repository;
  StreamSubscription<KosLoadResult<List<Kos>>>? _subscription;

  KosLoadResult<List<Kos>> _state = const KosLoadResult<List<Kos>>.loading();

  KosLoadResult<List<Kos>> get state => _state;

  void load() {
    _subscription?.cancel();
    _subscription = _repository.fetchList().listen((state) {
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
