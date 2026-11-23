import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class KosRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchList();

  Future<Map<String, dynamic>?> fetchById(String id);
}

class SupabaseKosRemoteDataSource implements KosRemoteDataSource {
  SupabaseKosRemoteDataSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<Map<String, dynamic>>> fetchList() async {
    final response = await client
        .from('kos')
        .select(
          'id,owner_id,name,address_area,price_monthly,facilities,'
          'total_rooms,available_rooms,status,created_at',
        )
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await client
        .from('kos')
        .select(
          'id,owner_id,name,address_area,price_monthly,facilities,'
          'total_rooms,available_rooms,status,created_at',
        )
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }
    return Map<String, dynamic>.from(response);
  }
}
