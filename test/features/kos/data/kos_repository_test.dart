import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/features/kos/data/kos_load_result.dart';
import 'package:kosfinder_vc/features/kos/data/kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/kos/data/kos_repository.dart';

class FakeKosRemoteDataSource implements KosRemoteDataSource {
  FakeKosRemoteDataSource({
    this.listResult = const [],
    this.detailResult,
    this.throwOnList = false,
    this.throwOnDetail = false,
  });

  final List<Map<String, dynamic>> listResult;
  final Map<String, dynamic>? detailResult;
  final bool throwOnList;
  final bool throwOnDetail;

  @override
  Future<List<Map<String, dynamic>>> fetchList() async {
    if (throwOnList) {
      throw Exception('network');
    }
    return listResult;
  }

  @override
  Future<Map<String, dynamic>?> fetchById(String id) async {
    if (throwOnDetail) {
      throw Exception('network');
    }
    return detailResult;
  }
}

void main() {
  final validJson = <String, dynamic>{
    'id': 'kos-1',
    'owner_id': 'owner-1',
    'name': 'Kos Melati',
    'address_area': 'Singaraja',
    'price_monthly': 900000,
    'facilities': ['AC', 'WiFi'],
    'total_rooms': 10,
    'available_rooms': 4,
    'status': 'Tersedia',
    'created_at': '2026-11-23T11:55:02.848437+00:00',
  };

  test('fetchList emits loading then success', () async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(listResult: [validJson]),
    );

    final states = await repository.fetchList().toList();

    expect(states.map((state) => state.status), [
      KosLoadStatus.loading,
      KosLoadStatus.success,
    ]);
    expect(states.last.data?.first.name, 'Kos Melati');
  });

  test('fetchList emits empty when Supabase returns no rows', () async {
    final repository = KosRepository(FakeKosRemoteDataSource());

    final states = await repository.fetchList().toList();

    expect(states.last.status, KosLoadStatus.empty);
  });

  test('fetchList emits error on connection failure', () async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(throwOnList: true),
    );

    final states = await repository.fetchList().toList();

    expect(states.last.status, KosLoadStatus.error);
    expect(states.last.message, 'Tidak dapat terhubung ke Supabase.');
  });

  test('fetchDetail emits loading then success', () async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(detailResult: validJson),
    );

    final states = await repository.fetchDetail('kos-1').toList();

    expect(states.map((state) => state.status), [
      KosLoadStatus.loading,
      KosLoadStatus.success,
    ]);
    expect(states.last.data?.id, 'kos-1');
  });

  test('fetchDetail emits notFound when ID has no row', () async {
    final repository = KosRepository(FakeKosRemoteDataSource());

    final states = await repository.fetchDetail('missing-id').toList();

    expect(states.last.status, KosLoadStatus.notFound);
  });

  test('fetchDetail emits error on connection failure', () async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(throwOnDetail: true),
    );

    final states = await repository.fetchDetail('kos-1').toList();

    expect(states.last.status, KosLoadStatus.error);
  });
}
