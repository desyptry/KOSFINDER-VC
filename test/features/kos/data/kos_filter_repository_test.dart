import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/features/kos/data/kos_filters.dart';
import 'package:kosfinder_vc/features/kos/data/kos_load_result.dart';
import 'package:kosfinder_vc/features/kos/data/kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/kos/data/kos_repository.dart';

class CapturingKosRemoteDataSource implements KosRemoteDataSource {
  CapturingKosRemoteDataSource({this.rows = const [], this.throwError = false});

  final List<Map<String, dynamic>> rows;
  final bool throwError;
  KosFilters receivedFilters = const KosFilters();

  @override
  Future<List<Map<String, dynamic>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]) async {
    receivedFilters = filters;
    if (throwError) {
      throw Exception('network');
    }
    return rows;
  }

  @override
  Future<Map<String, dynamic>?> fetchById(String id) async => null;
}

void main() {
  test('repository passes area filter to remote data source', () async {
    final remote = CapturingKosRemoteDataSource();
    final repository = KosRepository(remote);
    const filters = KosFilters(area: 'Singaraja');

    await repository.fetchList(filters).toList();

    expect(remote.receivedFilters.normalizedArea, 'Singaraja');
  });

  test('repository passes price range filter to remote data source', () async {
    final remote = CapturingKosRemoteDataSource();
    final repository = KosRepository(remote);
    const filters = KosFilters(minPrice: 500000, maxPrice: 1000000);

    await repository.fetchList(filters).toList();

    expect(remote.receivedFilters.minPrice, 500000);
    expect(remote.receivedFilters.maxPrice, 1000000);
  });

  test('repository passes facility filter to remote data source', () async {
    final remote = CapturingKosRemoteDataSource();
    final repository = KosRepository(remote);
    const filters = KosFilters(facilities: ['AC', 'WiFi']);

    await repository.fetchList(filters).toList();

    expect(remote.receivedFilters.normalizedFacilities, ['AC', 'WiFi']);
  });

  test('repository passes combined filters to remote data source', () async {
    final remote = CapturingKosRemoteDataSource();
    final repository = KosRepository(remote);
    const filters = KosFilters(
      area: 'Singaraja',
      minPrice: 500000,
      maxPrice: 1000000,
      facilities: ['AC', 'WiFi'],
    );

    await repository.fetchList(filters).toList();

    expect(remote.receivedFilters.normalizedArea, 'Singaraja');
    expect(remote.receivedFilters.minPrice, 500000);
    expect(remote.receivedFilters.maxPrice, 1000000);
    expect(remote.receivedFilters.normalizedFacilities, ['AC', 'WiFi']);
  });

  test('empty filter does not restrict remote query', () async {
    final remote = CapturingKosRemoteDataSource();
    final repository = KosRepository(remote);

    await repository.fetchList(const KosFilters()).toList();

    expect(remote.receivedFilters.isEmpty, isTrue);
  });

  test('filtered repository returns empty state', () async {
    final repository = KosRepository(CapturingKosRemoteDataSource());

    final states = await repository
        .fetchList(const KosFilters(area: 'Tidak Ada'))
        .toList();

    expect(states.last.status, KosLoadStatus.empty);
  });

  test('filtered repository returns error state', () async {
    final repository = KosRepository(
      CapturingKosRemoteDataSource(throwError: true),
    );

    final states = await repository
        .fetchList(const KosFilters(facilities: ['WiFi']))
        .toList();

    expect(states.last.status, KosLoadStatus.error);
  });

  test('invalid price range is rejected before remote query', () async {
    final remote = CapturingKosRemoteDataSource();
    final repository = KosRepository(remote);

    final states = await repository
        .fetchList(const KosFilters(minPrice: 1000000, maxPrice: 500000))
        .toList();

    expect(states.last.status, KosLoadStatus.error);
    expect(states.last.message, 'Rentang harga tidak valid.');
  });
}
