import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/features/kos/data/kos_filters.dart';
import 'package:kosfinder_vc/features/kos/data/kos_load_result.dart';
import 'package:kosfinder_vc/features/kos/data/kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/kos/data/kos_repository.dart';
import 'package:kosfinder_vc/features/kos/providers/kos_filter_provider.dart';

class ProviderFakeRemoteDataSource implements KosRemoteDataSource {
  ProviderFakeRemoteDataSource({this.rows = const [], this.throwError = false});

  final List<Map<String, dynamic>> rows;
  final bool throwError;

  @override
  Future<List<Map<String, dynamic>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]) async {
    if (throwError) {
      throw Exception('network');
    }
    return rows;
  }

  @override
  Future<Map<String, dynamic>?> fetchById(String id) async => null;
}

void main() {
  test('filter provider starts in loading and updates combined filters', () {
    final provider = KosFilterProvider(
      KosRepository(ProviderFakeRemoteDataSource()),
    );

    provider.setArea('Singaraja');
    provider.setPriceRange(500000, 1000000);
    provider.setFacilities(['AC', 'WiFi']);
    provider.apply();

    expect(provider.filters.normalizedArea, 'Singaraja');
    expect(provider.filters.minPrice, 500000);
    expect(provider.filters.maxPrice, 1000000);
    expect(provider.filters.normalizedFacilities, ['AC', 'WiFi']);

    provider.dispose();
  });

  test('filter provider clear removes all filters', () async {
    final provider = KosFilterProvider(
      KosRepository(ProviderFakeRemoteDataSource()),
    );

    provider.setArea('Singaraja');
    provider.setPriceRange(500000, 1000000);
    provider.setFacilities(['AC']);
    provider.clear();
    await Future<void>.delayed(Duration.zero);

    expect(provider.filters.isEmpty, isTrue);
    expect(provider.state.status, isNot(KosLoadStatus.loading));

    provider.dispose();
  });

  test('filter provider exposes empty state', () async {
    final provider = KosFilterProvider(
      KosRepository(ProviderFakeRemoteDataSource()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.state.status, KosLoadStatus.empty);

    provider.dispose();
  });

  test('filter provider exposes error state', () async {
    final provider = KosFilterProvider(
      KosRepository(ProviderFakeRemoteDataSource(throwError: true)),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.state.status, KosLoadStatus.error);

    provider.dispose();
  });
}
