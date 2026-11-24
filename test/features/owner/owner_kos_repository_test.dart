import 'package:flutter_test/flutter_test.dart';

import 'package:kosfinder_vc/features/owner/data/owner_kos_remote_data_source.dart';
import 'package:kosfinder_vc/features/owner/data/owner_kos_repository.dart';

class RecordingOwnerRemote implements OwnerKosRemoteDataSource {
  RecordingOwnerRemote({
    this.rows = const <Map<String, dynamic>>[],
    this.error,
    this.updateResult,
  });

  final List<Map<String, dynamic>> rows;
  final Object? error;
  final Map<String, dynamic>? updateResult;
  String? fetchedOwnerId;
  Map<String, dynamic>? insertedPayload;
  String? updatedId;
  String? updatedOwnerId;
  Map<String, dynamic>? updatedPayload;
  String? deletedId;
  String? deletedOwnerId;

  @override
  Future<List<Map<String, dynamic>>> fetchOwned(String ownerId) async {
    fetchedOwnerId = ownerId;
    if (error != null) {
      throw error!;
    }
    return rows;
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload) async {
    if (error != null) {
      throw error!;
    }
    insertedPayload = payload;
    return kosRow(ownerId: payload['owner_id'] as String);
  }

  @override
  Future<Map<String, dynamic>> update({
    required String id,
    required String ownerId,
    required Map<String, dynamic> payload,
  }) async {
    if (error != null) {
      throw error!;
    }
    updatedId = id;
    updatedOwnerId = ownerId;
    updatedPayload = payload;
    return updateResult ?? kosRow(id: id, ownerId: ownerId);
  }

  @override
  Future<void> delete({required String id, required String ownerId}) async {
    if (error != null) {
      throw error!;
    }
    deletedId = id;
    deletedOwnerId = ownerId;
  }
}

Map<String, dynamic> kosRow({
  String id = 'kos-1',
  required String ownerId,
  int availableRooms = 4,
  String status = 'Tersedia',
}) {
  return {
    'id': id,
    'owner_id': ownerId,
    'name': 'Kos Melati',
    'address_area': 'Singaraja',
    'price_monthly': 900000,
    'facilities': ['WiFi'],
    'total_rooms': 10,
    'available_rooms': availableRooms,
    'status': status,
    'created_at': '2026-11-24T00:00:00Z',
  };
}

Map<String, dynamic> draftPayload() {
  return {
    'owner_id': 'owner-1',
    'name': 'Kos Baru',
    'address_area': 'Singaraja',
    'price_monthly': 800000,
    'facilities': ['WiFi'],
    'total_rooms': 8,
    'available_rooms': 3,
  };
}

void main() {
  test('fetchOwned passes active owner ID to remote query', () async {
    final remote = RecordingOwnerRemote(rows: [kosRow(ownerId: 'owner-1')]);
    final repository = OwnerKosRepository(remote);

    final result = await repository.fetchOwned('owner-1');

    expect(remote.fetchedOwnerId, 'owner-1');
    expect(result.single.ownerId, 'owner-1');
  });

  test('insert sends owner ID and returns saved kos', () async {
    final remote = RecordingOwnerRemote();
    final repository = OwnerKosRepository(remote);

    final result = await repository.insert(
      ownerId: 'owner-1',
      payload: draftPayload(),
    );

    expect(remote.insertedPayload?['owner_id'], 'owner-1');
    expect(result.id, 'kos-1');
  });

  test('insert does not send database-managed columns', () async {
    final remote = RecordingOwnerRemote();
    final repository = OwnerKosRepository(remote);
    final payload = {
      ...draftPayload(),
      'id': 'client-id',
      'status': 'Penuh',
      'created_at': 'client-date',
    };

    await repository.insert(ownerId: 'owner-1', payload: payload);

    expect(remote.insertedPayload, isNot(contains('id')));
    expect(remote.insertedPayload, isNot(contains('status')));
    expect(remote.insertedPayload, isNot(contains('created_at')));
    expect(remote.insertedPayload?['owner_id'], 'owner-1');
  });

  test('update sends ID and owner filter without generated columns', () async {
    final remote = RecordingOwnerRemote();
    final repository = OwnerKosRepository(remote);
    final payload = {
      ...draftPayload(),
      'id': 'kos-1',
      'status': 'Penuh',
      'created_at': 'do-not-send',
    };

    await repository.update(id: 'kos-1', ownerId: 'owner-1', payload: payload);

    expect(remote.updatedId, 'kos-1');
    expect(remote.updatedOwnerId, 'owner-1');
    expect(remote.updatedPayload, isNot(contains('owner_id')));
    expect(remote.updatedPayload, isNot(contains('id')));
    expect(remote.updatedPayload, isNot(contains('status')));
    expect(remote.updatedPayload, isNot(contains('created_at')));
  });

  test('update reads database-generated full status from saved row', () async {
    final remote = RecordingOwnerRemote(
      updateResult: kosRow(
        id: 'kos-1',
        ownerId: 'owner-1',
        availableRooms: 0,
        status: 'Penuh',
      ),
    );
    final repository = OwnerKosRepository(remote);

    final result = await repository.update(
      id: 'kos-1',
      ownerId: 'owner-1',
      payload: {...draftPayload(), 'available_rooms': 0},
    );

    expect(result.availableRooms, 0);
    expect(result.status, 'Penuh');
  });

  test('insert error is reported without success result', () async {
    final repository = OwnerKosRepository(
      RecordingOwnerRemote(error: Exception('offline')),
    );

    expect(
      () => repository.insert(ownerId: 'owner-1', payload: draftPayload()),
      throwsA(
        isA<OwnerKosException>().having(
          (error) => error.message,
          'message',
          'Tidak dapat menyimpan kos ke Supabase.',
        ),
      ),
    );
  });

  test('update error for another owner is rejected', () async {
    final repository = OwnerKosRepository(
      RecordingOwnerRemote(
        error: const OwnerKosRemoteException(
          'Kos tidak ditemukan atau bukan milik Anda.',
        ),
      ),
    );

    expect(
      () => repository.update(
        id: 'kos-owner-a',
        ownerId: 'owner-b',
        payload: draftPayload(),
      ),
      throwsA(
        isA<OwnerKosException>().having(
          (error) => error.message,
          'message',
          'Kos tidak ditemukan atau bukan milik Anda.',
        ),
      ),
    );
  });

  test('delete sends kos ID and active owner ID', () async {
    final remote = RecordingOwnerRemote();
    final repository = OwnerKosRepository(remote);

    await repository.delete(id: 'kos-1', ownerId: 'owner-1');

    expect(remote.deletedId, 'kos-1');
    expect(remote.deletedOwnerId, 'owner-1');
  });

  test('delete error for another owner is translated', () async {
    final repository = OwnerKosRepository(
      RecordingOwnerRemote(
        error: const OwnerKosRemoteException(
          'Kos tidak ditemukan atau bukan milik Anda.',
        ),
      ),
    );

    expect(
      () => repository.delete(id: 'kos-owner-a', ownerId: 'owner-b'),
      throwsA(
        isA<OwnerKosException>().having(
          (error) => error.message,
          'message',
          'Kos tidak ditemukan atau bukan milik Anda.',
        ),
      ),
    );
  });
}
