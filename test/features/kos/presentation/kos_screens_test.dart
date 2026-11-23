import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kosfinder_vc/features/kos/data/kos_filters.dart';
import 'package:kosfinder_vc/features/kos/data/kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/kos/data/kos_repository.dart';
import 'package:kosfinder_vc/features/kos/presentation/kos_detail_screen.dart';
import 'package:kosfinder_vc/features/kos/presentation/kos_list_screen.dart';

class FakeKosRemoteDataSource implements KosRemoteDataSource {
  FakeKosRemoteDataSource({this.listResult = const [], this.detailResult});

  final List<Map<String, dynamic>> listResult;
  final Map<String, dynamic>? detailResult;

  @override
  Future<List<Map<String, dynamic>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]) async => listResult;

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
}
