import '../models/kos.dart';
import 'kos_filters.dart';
import 'kos_load_result.dart';
import 'kos_remote_data_source.dart';

class KosRepository {
  KosRepository(this._remoteDataSource);

  final KosRemoteDataSource _remoteDataSource;

  Stream<KosLoadResult<List<Kos>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]) async* {
    yield const KosLoadResult<List<Kos>>.loading();

    if (!filters.isValid) {
      yield const KosLoadResult<List<Kos>>.error('Rentang harga tidak valid.');
      return;
    }

    try {
      final rows = await _remoteDataSource.fetchList(filters);
      if (rows.isEmpty) {
        yield const KosLoadResult<List<Kos>>.empty();
        return;
      }

      final kosList = rows.map(Kos.fromJson).toList(growable: false);
      yield KosLoadResult<List<Kos>>.success(kosList);
    } on FormatException {
      yield const KosLoadResult<List<Kos>>.error(
        'Data kos tidak dapat dibaca.',
      );
    } catch (_) {
      yield const KosLoadResult<List<Kos>>.error(
        'Tidak dapat terhubung ke Supabase.',
      );
    }
  }

  Stream<KosLoadResult<Kos>> fetchDetail(String id) async* {
    yield const KosLoadResult<Kos>.loading();

    if (id.trim().isEmpty) {
      yield const KosLoadResult<Kos>.notFound();
      return;
    }

    try {
      final row = await _remoteDataSource.fetchById(id);
      if (row == null) {
        yield const KosLoadResult<Kos>.notFound();
        return;
      }

      yield KosLoadResult<Kos>.success(Kos.fromJson(row));
    } on FormatException {
      yield const KosLoadResult<Kos>.error('Data kos tidak dapat dibaca.');
    } catch (_) {
      yield const KosLoadResult<Kos>.error(
        'Tidak dapat terhubung ke Supabase.',
      );
    }
  }
}
