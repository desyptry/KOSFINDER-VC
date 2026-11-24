import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../auth/providers/auth_provider.dart';
import '../../kos/models/kos.dart';
import '../data/owner_kos_repository.dart';

enum OwnerKosStatus { loading, success, empty, error }

class OwnerKosState {
  const OwnerKosState({
    required this.status,
    this.data = const <Kos>[],
    this.message,
  });

  const OwnerKosState.loading() : this(status: OwnerKosStatus.loading);

  const OwnerKosState.success(List<Kos> data)
    : this(status: OwnerKosStatus.success, data: data);

  const OwnerKosState.empty() : this(status: OwnerKosStatus.empty);

  const OwnerKosState.error(String message)
    : this(status: OwnerKosStatus.error, message: message);

  final OwnerKosStatus status;
  final List<Kos> data;
  final String? message;
}

class OwnerKosProvider extends ChangeNotifier {
  OwnerKosProvider({required this._repository, required this._authProvider}) {
    unawaited(load());
  }

  final OwnerKosRepository _repository;
  final AuthProvider _authProvider;

  OwnerKosState _state = const OwnerKosState.loading();
  bool _isSaving = false;
  bool _isDeleting = false;

  OwnerKosState get state => _state;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;

  Future<void> load() async {
    _state = const OwnerKosState.loading();
    notifyListeners();

    final ownerId = _authProvider.user?.id;
    if (ownerId == null || ownerId.isEmpty) {
      _state = const OwnerKosState.error(
        'Sesi pemilik tidak tersedia. Silakan masuk kembali.',
      );
      notifyListeners();
      return;
    }

    try {
      final ownerKos = await _repository.fetchOwned(ownerId);
      _state = ownerKos.isEmpty
          ? const OwnerKosState.empty()
          : OwnerKosState.success(ownerKos);
    } on OwnerKosException catch (error) {
      _state = OwnerKosState.error(error.message);
    } finally {
      notifyListeners();
    }
  }

  Future<void> saveDraft({
    required OwnerKosDraft draft,
    Kos? existingKos,
  }) async {
    final ownerId = _authProvider.user?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const OwnerKosException(
        'Sesi pemilik tidak tersedia. Silakan masuk kembali.',
      );
    }

    _isSaving = true;
    notifyListeners();
    try {
      final payload = draft.toPendingPayload(ownerId);
      if (existingKos == null) {
        await _repository.insert(ownerId: ownerId, payload: payload);
      } else {
        await _repository.update(
          id: existingKos.id,
          ownerId: ownerId,
          payload: payload,
        );
      }
      await load();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteKos(String kosId) async {
    final ownerId = _authProvider.user?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const OwnerKosException(
        'Sesi pemilik tidak tersedia. Silakan masuk kembali.',
      );
    }
    if (_isDeleting) {
      return;
    }

    _isDeleting = true;
    notifyListeners();
    try {
      await _repository.delete(id: kosId, ownerId: ownerId);
      await load();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}

class OwnerKosDraft {
  const OwnerKosDraft({
    required this.name,
    required this.addressArea,
    required this.priceMonthly,
    required this.facilities,
    required this.totalRooms,
    required this.availableRooms,
  });

  final String name;
  final String addressArea;
  final int priceMonthly;
  final List<String> facilities;
  final int totalRooms;
  final int availableRooms;

  Map<String, dynamic> toPendingPayload(String ownerId) {
    return {
      'owner_id': ownerId,
      'name': name,
      'address_area': addressArea,
      'price_monthly': priceMonthly,
      'facilities': facilities,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
    };
  }
}

class OwnerKosFormValidation {
  const OwnerKosFormValidation._();

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi.';
    }
    return null;
  }

  static String? nonNegativeInteger(String? value, String label) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return '$label harus berupa angka minimal 0.';
    }
    return null;
  }

  static String? positiveInteger(String? value, String label) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return '$label harus berupa bilangan bulat lebih dari 0.';
    }
    return null;
  }

  static String? availableRooms(String? value, String totalRoomsValue) {
    final available = int.tryParse(value?.trim() ?? '');
    final total = int.tryParse(totalRoomsValue.trim());
    if (available == null || available < 0) {
      return 'Jumlah kamar tersedia harus berupa angka minimal 0.';
    }
    if (total != null && available > total) {
      return 'Jumlah kamar tersedia tidak boleh melebihi total kamar.';
    }
    return null;
  }
}
