import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kosfinder_vc/features/kos/data/kos_filters.dart';
import 'package:kosfinder_vc/features/kos/data/kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/kos/data/kos_repository.dart';
import 'package:kosfinder_vc/features/kos/presentation/kos_detail_screen.dart';
import 'package:kosfinder_vc/features/kos/presentation/kos_list_screen.dart';

class FakeKosRemoteDataSource implements KosRemoteDataSource {
  FakeKosRemoteDataSource({
    this.listResult = const [],
    this.detailResult,
    this.throwOnList = false,
  });

  final List<Map<String, dynamic>> listResult;
  final Map<String, dynamic>? detailResult;
  final bool throwOnList;
  KosFilters lastFilters = const KosFilters();

  @override
  Future<List<Map<String, dynamic>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]) async {
    lastFilters = filters;
    if (throwOnList) {
      throw Exception('network');
    }
    return listResult;
  }

  @override
  Future<Map<String, dynamic>?> fetchById(String id) async => detailResult;
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

  Widget testApp(KosRepository repository, {Widget? home}) {
    return Provider<KosRepository>.value(
      value: repository,
      child: MaterialApp(home: home ?? const KosListScreen()),
    );
  }

  testWidgets('list screen shows empty state', (tester) async {
    final repository = KosRepository(FakeKosRemoteDataSource());

    await tester.pumpWidget(testApp(repository));
    await tester.pump();

    expect(find.text('Belum ada kos yang tersedia.'), findsOneWidget);
  });

  testWidgets('list screen navigates to detail screen', (tester) async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(listResult: [validJson]),
    );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    await tester.tap(find.text('Kos Melati'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Kos'), findsOneWidget);
  });

  testWidgets('detail screen shows Kos fields', (tester) async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(detailResult: validJson),
    );

    await tester.pumpWidget(
      testApp(repository, home: const KosDetailScreen(kosId: 'kos-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    expect(find.text('Singaraja'), findsOneWidget);
    expect(find.text('Rp 900.000 / bulan'), findsOneWidget);
    expect(find.text('Tersedia'), findsOneWidget);
  });

  testWidgets('detail screen shows not found state', (tester) async {
    final repository = KosRepository(FakeKosRemoteDataSource());

    await tester.pumpWidget(
      testApp(repository, home: const KosDetailScreen(kosId: 'missing')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos tidak ditemukan.'), findsOneWidget);
  });

  testWidgets('filter area, prices, and facilities server-side', (
    tester,
  ) async {
    final remote = FakeKosRemoteDataSource(listResult: [validJson]);
    final repository = KosRepository(remote);

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('filter-panel')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('area-filter')), 'Singaraja');
    await tester.enterText(find.byKey(const Key('min-price-filter')), '500000');
    await tester.enterText(
      find.byKey(const Key('max-price-filter')),
      '1000000',
    );
    await tester.tap(find.byKey(const Key('facility-AC')));
    await tester.tap(find.byKey(const Key('facility-WiFi')));
    await tester.tap(find.byKey(const Key('apply-filter')));
    await tester.pumpAndSettle();

    expect(remote.lastFilters.normalizedArea, 'Singaraja');
    expect(remote.lastFilters.minPrice, 500000);
    expect(remote.lastFilters.maxPrice, 1000000);
    expect(remote.lastFilters.normalizedFacilities, ['AC', 'WiFi']);
  });

  testWidgets('reset filter clears every criterion', (tester) async {
    final remote = FakeKosRemoteDataSource(listResult: [validJson]);
    final repository = KosRepository(remote);

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('filter-panel')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('area-filter')), 'Singaraja');
    await tester.tap(find.byKey(const Key('facility-AC')));
    await tester.tap(find.byKey(const Key('apply-filter')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reset-filter')));
    await tester.pumpAndSettle();

    expect(remote.lastFilters.isEmpty, isTrue);
  });

  testWidgets('filter result can open detail', (tester) async {
    final remote = FakeKosRemoteDataSource(listResult: [validJson]);
    final repository = KosRepository(remote);

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-panel')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('area-filter')), 'Singaraja');
    await tester.tap(find.byKey(const Key('apply-filter')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kos Melati'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Kos'), findsOneWidget);
  });

  testWidgets('filter error state shows retry', (tester) async {
    final repository = KosRepository(
      FakeKosRemoteDataSource(throwOnList: true),
    );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Tidak dapat terhubung ke Supabase.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
