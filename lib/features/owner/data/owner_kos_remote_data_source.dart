import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class OwnerKosRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchOwned(String ownerId);

  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> update({
    required String id,
    required String ownerId,
    required Map<String, dynamic> payload,
  });

  Future<void> delete({required String id, required String ownerId});
}

class SupabaseOwnerKosRemoteDataSource implements OwnerKosRemoteDataSource {
  SupabaseOwnerKosRemoteDataSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<Map<String, dynamic>>> fetchOwned(String ownerId) async {
    final response = await client
        .from('kos')
        .select(_columns)
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload) async {
    final response = await client
        .from('kos')
        .insert(payload)
        .select(_columns)
        .single();
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Map<String, dynamic>> update({
    required String id,
    required String ownerId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await client
        .from('kos')
        .update(payload)
        .eq('id', id)
        .eq('owner_id', ownerId)
        .select(_columns)
        .maybeSingle();

    if (response == null) {
      throw const OwnerKosRemoteException(
        'Kos tidak ditemukan atau bukan milik Anda.',
      );
    }
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<void> delete({required String id, required String ownerId}) async {
    final response = await client
        .from('kos')
        .delete()
        .eq('id', id)
        .eq('owner_id', ownerId)
        .select('id');

    if (response.isEmpty) {
      throw const OwnerKosRemoteException(
        'Kos tidak ditemukan atau bukan milik Anda.',
      );
    }
  }
}

const _columns =
    'id,owner_id,name,address_area,price_monthly,facilities,'
    'total_rooms,available_rooms,status,created_at';

class OwnerKosRemoteException implements Exception {
  const OwnerKosRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}
