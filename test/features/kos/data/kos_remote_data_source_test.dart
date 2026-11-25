import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/features/kos/data/kos_filters.dart';
import 'package:kosfinder_vc/features/kos/data/kos_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('fetchList sends combined filters to the PostgREST query', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requestUri = Completer<Uri>();
    final subscription = server.listen((request) async {
      requestUri.complete(request.uri);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode([
            {
              'id': 'matching-kos',
              'name': 'Kos Melati',
              'address_area': 'Singaraja',
              'price_monthly': 750000,
              'facilities': ['AC', 'WiFi'],
              'total_rooms': 10,
              'available_rooms': 4,
              'status': 'Tersedia',
              'created_at': '2026-11-23T11:55:02.848437+00:00',
            },
          ]),
        );
      await request.response.close();
    });
    final client = SupabaseClient(
      'http://${server.address.address}:${server.port}',
      'test-anon-key',
    );

    try {
      final rows = await SupabaseKosRemoteDataSource(client).fetchList(
        const KosFilters(
          area: 'Singaraja',
          minPrice: 500000,
          maxPrice: 1000000,
          facilities: ['AC', 'WiFi'],
        ),
      );
      final uri = await requestUri.future;

      expect(uri.path, '/rest/v1/kos');
      expect(uri.queryParametersAll['address_area'], ['ilike.%Singaraja%']);
      expect(uri.queryParametersAll['price_monthly'], [
        'gte.500000',
        'lte.1000000',
      ]);
      expect(uri.queryParametersAll['facilities'], ['cs.{"AC","WiFi"}']);
      expect(uri.queryParametersAll['order'], ['created_at.desc.nullslast']);
      expect(rows.map((row) => row['id']), ['matching-kos']);
    } finally {
      await client.dispose();
      await subscription.cancel();
      await server.close(force: true);
    }
  });
}
