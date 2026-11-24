import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder_vc/features/auth/data/auth_gateway.dart';
import 'package:kosfinder_vc/features/auth/data/auth_repository.dart';
import 'package:kosfinder_vc/features/auth/providers/auth_provider.dart';
import 'package:kosfinder_vc/features/kos/models/kos.dart';
import 'package:kosfinder_vc/features/owner/data/owner_kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/owner/data/owner_kos_repository.dart';
import 'package:kosfinder_vc/features/owner/presentation/owner_kos_form_screen.dart';
import 'package:kosfinder_vc/features/owner/presentation/owner_kos_list_screen.dart';
import 'package:kosfinder_vc/features/owner/providers/owner_kos_provider.dart';

class FakeKosRemoteDataSource implements OwnerKosRemoteDataSource {
  FakeKosRemoteDataSource({
    this.rows = const <Map<String, dynamic>>[],
    this.error,
    this.deleteError,
    this.delay = Duration.zero,
    this.deleteDelay = Duration.zero,
  });

  final List<Map<String, dynamic>> rows;
  final Object? error;
  final Object? deleteError;
  final Duration delay;
  final Duration deleteDelay;
  String? requestedOwnerId;
  String? deletedId;
  String? deletedOwnerId;
  int deleteCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchOwned(String ownerId) async {
    requestedOwnerId = ownerId;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (error != null) {
      throw error!;
    }
    return rows
        .where((row) => row['owner_id'] == ownerId)
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload) async {
    return kosJson(id: 'inserted', ownerId: payload['owner_id'] as String);
  }

  @override
  Future<Map<String, dynamic>> update({
    required String id,
    required String ownerId,
    required Map<String, dynamic> payload,
  }) async {
    return kosJson(id: id, ownerId: ownerId);
  }

  @override
  Future<void> delete({required String id, required String ownerId}) async {
    if (deleteError != null) {
      throw deleteError!;
    }
    if (deleteDelay > Duration.zero) {
      await Future<void>.delayed(deleteDelay);
    }
    deleteCalls++;
    deletedId = id;
    deletedOwnerId = ownerId;
    rows.removeWhere((row) => row['id'] == id && row['owner_id'] == ownerId);
  }
}

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway(this.user)
    : session = Session(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        tokenType: 'bearer',
        user: user,
      ),
      controller = StreamController<AuthState>.broadcast();

  User user;
  final Session session;
  final StreamController<AuthState> controller;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async => AuthResponse(user: user, session: session);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async => AuthResponse(user: user, session: session);

  @override
  Future<void> signOut() async {}

  @override
  Session? get currentSession => session;

  @override
  User? get currentUser => user;

  @override
  Stream<AuthState> get onAuthStateChange => controller.stream;
}

User ownerUser() {
  return const User(
    id: 'owner-1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    email: 'owner@example.com',
    createdAt: '2026-11-24T00:00:00Z',
  );
}

Map<String, dynamic> kosJson({
  required String id,
  required String ownerId,
  String name = 'Kos Melati',
}) {
  return {
    'id': id,
    'owner_id': ownerId,
    'name': name,
    'address_area': 'Singaraja',
    'price_monthly': 900000,
    'facilities': ['WiFi'],
    'total_rooms': 10,
    'available_rooms': 4,
    'status': 'Tersedia',
    'created_at': '2026-11-24T00:00:00Z',
  };
}

AuthProvider authProvider() {
  return AuthProvider(AuthRepository.withGateway(FakeAuthGateway(ownerUser())));
}

void main() {
  testWidgets('owner list shows only kos owned by current user', (
    tester,
  ) async {
    final provider = authProvider();
    final repository = OwnerKosRepository(
      FakeKosRemoteDataSource(
        rows: [
          kosJson(id: 'owned', ownerId: 'owner-1'),
          kosJson(id: 'other', ownerId: 'owner-2', name: 'Kos Orang Lain'),
        ],
      ),
    );
    final ownerProvider = OwnerKosProvider(
      repository: repository,
      authProvider: provider,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: ownerProvider),
        ],
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    expect(find.text('Kos Orang Lain'), findsNothing);
    provider.dispose();
    ownerProvider.dispose();
  });

  testWidgets('owner list shows empty and error states', (tester) async {
    final provider = authProvider();
    final emptyOwnerProvider = OwnerKosProvider(
      repository: OwnerKosRepository(FakeKosRemoteDataSource()),
      authProvider: provider,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: emptyOwnerProvider),
        ],
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Anda belum memiliki kos.'), findsOneWidget);

    final errorOwnerProvider = OwnerKosProvider(
      repository: OwnerKosRepository(
        FakeKosRemoteDataSource(error: Exception('offline')),
      ),
      authProvider: provider,
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: errorOwnerProvider),
        ],
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak dapat memuat kos milik Anda dari Supabase.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);

    provider.dispose();
    emptyOwnerProvider.dispose();
    errorOwnerProvider.dispose();
  });

  testWidgets('delete dialog shows kos name and cancel keeps data', (
    tester,
  ) async {
    final auth = authProvider();
    final remote = FakeKosRemoteDataSource(
      rows: [kosJson(id: 'owned', ownerId: 'owner-1')],
    );
    final ownerProvider = OwnerKosProvider(
      repository: OwnerKosRepository(remote),
      authProvider: auth,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: ownerProvider),
        ],
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-delete-owned')));
    await tester.pumpAndSettle();

    expect(find.text('Kos "Kos Melati" akan dihapus.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('owner-delete-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    expect(remote.deleteCalls, 0);
    auth.dispose();
    ownerProvider.dispose();
  });

  testWidgets('confirmed delete reloads list and shows success', (
    tester,
  ) async {
    final auth = authProvider();
    final remote = FakeKosRemoteDataSource(
      rows: [kosJson(id: 'owned', ownerId: 'owner-1')],
    );
    final ownerProvider = OwnerKosProvider(
      repository: OwnerKosRepository(remote),
      authProvider: auth,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: ownerProvider),
        ],
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-delete-owned')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-delete-confirm')));
    await tester.pumpAndSettle();

    expect(remote.deletedId, 'owned');
    expect(find.text('Kos Melati'), findsNothing);
    expect(find.text('Kos berhasil dihapus.'), findsOneWidget);
    auth.dispose();
    ownerProvider.dispose();
  });

  testWidgets('delete error keeps item and shows error message', (
    tester,
  ) async {
    final auth = authProvider();
    final remote = FakeKosRemoteDataSource(
      rows: [kosJson(id: 'owned', ownerId: 'owner-1')],
      deleteError: Exception('offline'),
    );
    final ownerProvider = OwnerKosProvider(
      repository: OwnerKosRepository(remote),
      authProvider: auth,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: ownerProvider),
        ],
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-delete-owned')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    expect(
      find.text('Tidak dapat menghapus kos dari Supabase.'),
      findsOneWidget,
    );
    auth.dispose();
    ownerProvider.dispose();
  });

  test('provider ignores a repeated delete while first is loading', () async {
    final auth = authProvider();
    final remote = FakeKosRemoteDataSource(
      rows: [kosJson(id: 'owned', ownerId: 'owner-1')],
      deleteDelay: const Duration(milliseconds: 20),
    );
    final ownerProvider = OwnerKosProvider(
      repository: OwnerKosRepository(remote),
      authProvider: auth,
    );

    final first = ownerProvider.deleteKos('owned');
    final second = ownerProvider.deleteKos('owned');
    await Future.wait([first, second]);

    expect(remote.deleteCalls, 1);
    auth.dispose();
    ownerProvider.dispose();
  });

  test('owner provider exposes loading before delayed result', () async {
    final auth = authProvider();
    final provider = OwnerKosProvider(
      repository: OwnerKosRepository(
        FakeKosRemoteDataSource(delay: const Duration(milliseconds: 20)),
      ),
      authProvider: auth,
    );

    expect(provider.state.status, OwnerKosStatus.loading);
    await provider.load();
    expect(provider.state.status, OwnerKosStatus.empty);
    provider.dispose();
    auth.dispose();
  });

  test('Kos model accepts database-generated full status', () {
    final kos = Kos.fromJson(
      kosJson(id: 'full', ownerId: 'owner-1')
        ..['available_rooms'] = 0
        ..['status'] = 'Penuh',
    );

    expect(kos.availableRooms, 0);
    expect(kos.status, 'Penuh');
  });

  test('Kos model rejects status inconsistent with available rooms', () {
    final invalid = kosJson(id: 'invalid', ownerId: 'owner-1')
      ..['available_rooms'] = 0
      ..['status'] = 'Tersedia';

    expect(() => Kos.fromJson(invalid), throwsFormatException);
  });

  test('Kos model rejects negative available rooms', () {
    final invalid = kosJson(id: 'negative', ownerId: 'owner-1')
      ..['available_rooms'] = -1;

    expect(() => Kos.fromJson(invalid), throwsFormatException);
  });

  test('Kos model rejects available rooms above total rooms', () {
    final invalid = kosJson(id: 'too-many', ownerId: 'owner-1')
      ..['available_rooms'] = 11;

    expect(() => Kos.fromJson(invalid), throwsFormatException);
  });

  testWidgets('empty fields are rejected by owner form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OwnerKosFormScreen()));
    await tester.tap(find.byKey(const Key('owner-kos-submit')));
    await tester.pump();

    expect(find.text('Nama kos wajib diisi.'), findsOneWidget);
    expect(find.text('Alamat/wilayah wajib diisi.'), findsOneWidget);
    expect(find.text('Harga harus berupa angka minimal 0.'), findsOneWidget);
    expect(
      find.text('Total kamar harus berupa bilangan bulat lebih dari 0.'),
      findsOneWidget,
    );
    expect(
      find.text('Jumlah kamar tersedia harus berupa angka minimal 0.'),
      findsOneWidget,
    );
  });

  testWidgets('owner form validates numeric constraints', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OwnerKosFormScreen()));
    await tester.enterText(
      find.byKey(const Key('owner-kos-name')),
      'Kos Melati',
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-area')),
      'Singaraja',
    );
    await tester.enterText(find.byKey(const Key('owner-kos-price')), '-1');
    await tester.enterText(find.byKey(const Key('owner-kos-total-rooms')), '2');
    await tester.enterText(
      find.byKey(const Key('owner-kos-available-rooms')),
      '3',
    );
    await tester.tap(find.byKey(const Key('owner-kos-submit')));
    await tester.pump();

    expect(find.text('Harga harus berupa angka minimal 0.'), findsOneWidget);
    expect(
      find.text('Jumlah kamar tersedia tidak boleh melebihi total kamar.'),
      findsOneWidget,
    );
  });

  testWidgets('valid owner form produces draft without database fields', (
    tester,
  ) async {
    OwnerKosDraft? draft;
    await tester.pumpWidget(
      MaterialApp(
        home: OwnerKosFormScreen(onDraftCreated: (value) => draft = value),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-name')),
      'Kos Melati',
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-area')),
      'Singaraja',
    );
    await tester.enterText(find.byKey(const Key('owner-kos-price')), '900000');
    await tester.enterText(
      find.byKey(const Key('owner-kos-total-rooms')),
      '10',
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-available-rooms')),
      '4',
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-facilities')),
      'WiFi, AC',
    );
    await tester.tap(find.byKey(const Key('owner-kos-submit')));
    await tester.pump();

    expect(draft?.name, 'Kos Melati');
    expect(draft?.facilities, ['WiFi', 'AC']);
    expect(draft?.toPendingPayload('owner-1').keys, isNot(contains('status')));
    expect(draft?.toPendingPayload('owner-1').keys, isNot(contains('id')));
    expect(find.byKey(const Key('owner-kos-draft-message')), findsOneWidget);
  });

  testWidgets('owner form displays backend save error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OwnerKosFormScreen(
          onSave: (_) async {
            throw const OwnerKosException('Tidak dapat menyimpan kos.');
          },
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-name')),
      'Kos Melati',
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-area')),
      'Singaraja',
    );
    await tester.enterText(find.byKey(const Key('owner-kos-price')), '900000');
    await tester.enterText(
      find.byKey(const Key('owner-kos-total-rooms')),
      '10',
    );
    await tester.enterText(
      find.byKey(const Key('owner-kos-available-rooms')),
      '4',
    );
    await tester.tap(find.byKey(const Key('owner-kos-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('owner-kos-save-error')), findsOneWidget);
    expect(find.text('Tidak dapat menyimpan kos.'), findsOneWidget);
  });

  testWidgets('edit form is prefilled from selected kos', (tester) async {
    final kos = Kos.fromJson(kosJson(id: 'owned', ownerId: 'owner-1'));
    await tester.pumpWidget(
      MaterialApp(home: OwnerKosFormScreen(initialKos: kos)),
    );

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('owner-kos-name')))
          .controller
          ?.text,
      'Kos Melati',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('owner-kos-total-rooms')))
          .controller
          ?.text,
      '10',
    );
    expect(find.text('Edit Kos'), findsOneWidget);
  });
}
