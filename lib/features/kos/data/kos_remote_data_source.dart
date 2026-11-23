import 'package:supabase_flutter/supabase_flutter.dart';

import 'kos_filters.dart';

abstract interface class KosRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]);

  Future<Map<String, dynamic>?> fetchById(String id);
}

class SupabaseKosRemoteDataSource implements KosRemoteDataSource {
  SupabaseKosRemoteDataSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<Map<String, dynamic>>> fetchList([
    KosFilters filters = const KosFilters(),
  ]) async {
    var query = client
        .from('kos')
        .select(
          'id,owner_id,name,address_area,price_monthly,facilities,'
          'total_rooms,available_rooms,status,created_at',
        );

    final area = filters.normalizedArea;
    if (area != null) {
      query = query.ilike('address_area', '%${_escapeLikePattern(area)}%');
    }

    if (filters.minPrice != null) {
      query = query.gte('price_monthly', filters.minPrice!);
    }

    if (filters.maxPrice != null) {
      query = query.lte('price_monthly', filters.maxPrice!);
    }

    final facilities = filters.normalizedFacilities;
    if (facilities.isNotEmpty) {
      query = query.contains('facilities', facilities);
    }

    final response = await query.order('created_at', ascending: false);

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

String _escapeLikePattern(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
