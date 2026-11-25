import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/features/kos/models/kos.dart';

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

  test('Kos.fromJson reads public data without owner_id', () {
    final publicJson = Map<String, dynamic>.from(validJson)
      ..remove('owner_id');

    final kos = Kos.fromJson(publicJson);

    expect(kos.id, 'kos-1');
    expect(kos.ownerId, isNull);
    expect(kos.name, 'Kos Melati');
    expect(kos.availableRooms, 4);
    expect(kos.toJson(), isNot(contains('owner_id')));
  });

  test('Kos.fromJson retains owner_id when returned by owner query', () {
    final kos = Kos.fromJson(validJson);

    expect(kos.id, 'kos-1');
    expect(kos.ownerId, 'owner-1');
    expect(kos.name, 'Kos Melati');
    expect(kos.addressArea, 'Singaraja');
    expect(kos.priceMonthly, 900000);
    expect(kos.facilities, ['AC', 'WiFi']);
    expect(kos.totalRooms, 10);
    expect(kos.availableRooms, 4);
    expect(kos.status, 'Tersedia');
  });

  test('Kos.toJson produces Supabase column keys', () {
    final kos = Kos.fromJson(validJson);

    expect(kos.toJson()['price_monthly'], 900000);
    expect(kos.toJson()['address_area'], 'Singaraja');
    expect(kos.toJson()['available_rooms'], 4);
  });

  test('Kos.fromJson rejects incomplete data', () {
    final incompleteJson = Map<String, dynamic>.from(validJson)
      ..remove('name');

    expect(() => Kos.fromJson(incompleteJson), throwsFormatException);
  });
}
