import '../../kos/models/kos.dart';
import 'owner_kos_remote_data_source.dart';

class OwnerKosRepository {
  OwnerKosRepository(this._remoteDataSource);

  final OwnerKosRemoteDataSource _remoteDataSource;

  Future<List<Kos>> fetchOwned(String ownerId) async {
    _validateOwnerId(ownerId);
    try {
      final rows = await _remoteDataSource.fetchOwned(ownerId);
      return rows.map(Kos.fromJson).toList(growable: false);
    } on OwnerKosRemoteException catch (error) {
      throw OwnerKosException(error.message);
    } on FormatException {
      throw const OwnerKosException('Data kos tidak dapat dibaca.');
    } catch (_) {
      throw const OwnerKosException(
        'Tidak dapat memuat kos milik Anda dari Supabase.',
      );
    }
  }

  Future<Kos> insert({
    required String ownerId,
    required Map<String, dynamic> payload,
  }) async {
    _validateOwnerId(ownerId);
    try {
      final insertPayload = Map<String, dynamic>.from(payload)
        ..remove('id')
        ..remove('status')
        ..remove('created_at');
      final row = await _remoteDataSource.insert({
        ...insertPayload,
        'owner_id': ownerId,
      });
      return Kos.fromJson(row);
    } on OwnerKosRemoteException catch (error) {
      throw OwnerKosException(error.message);
    } on FormatException {
      throw const OwnerKosException('Data kos tersimpan tidak dapat dibaca.');
    } catch (_) {
      throw const OwnerKosException('Tidak dapat menyimpan kos ke Supabase.');
    }
  }

  Future<Kos> update({
    required String id,
    required String ownerId,
    required Map<String, dynamic> payload,
  }) async {
    _validateOwnerId(ownerId);
    if (id.trim().isEmpty) {
      throw const OwnerKosException('ID kos tidak valid.');
    }

    try {
      final updatePayload = Map<String, dynamic>.from(payload)
        ..remove('owner_id')
        ..remove('id')
        ..remove('status')
        ..remove('created_at');
      final row = await _remoteDataSource.update(
        id: id,
        ownerId: ownerId,
        payload: updatePayload,
      );
      return Kos.fromJson(row);
    } on OwnerKosRemoteException catch (error) {
      throw OwnerKosException(error.message);
    } on FormatException {
      throw const OwnerKosException('Data kos tersimpan tidak dapat dibaca.');
    } catch (_) {
      throw const OwnerKosException('Tidak dapat memperbarui kos di Supabase.');
    }
  }

  Future<void> delete({required String id, required String ownerId}) async {
    _validateOwnerId(ownerId);
    if (id.trim().isEmpty) {
      throw const OwnerKosException('ID kos tidak valid.');
    }

    try {
      await _remoteDataSource.delete(id: id, ownerId: ownerId);
    } on OwnerKosRemoteException catch (error) {
      throw OwnerKosException(error.message);
    } catch (_) {
      throw const OwnerKosException('Tidak dapat menghapus kos dari Supabase.');
    }
  }

  static void _validateOwnerId(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw const OwnerKosException(
        'Sesi pemilik tidak tersedia. Silakan masuk kembali.',
      );
    }
  }
}

class OwnerKosException implements Exception {
  const OwnerKosException(this.message);

  final String message;

  @override
  String toString() => message;
}
