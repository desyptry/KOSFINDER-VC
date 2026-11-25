class Kos {
  const Kos({
    required this.id,
    this.ownerId,
    required this.name,
    required this.addressArea,
    required this.priceMonthly,
    required this.facilities,
    required this.totalRooms,
    required this.availableRooms,
    required this.status,
    required this.createdAt,
  });

  factory Kos.fromJson(Map<String, dynamic> json) {
    final price = json['price_monthly'];
    final totalRooms = json['total_rooms'];
    final availableRooms = json['available_rooms'];
    final ownerId = json['owner_id'];

    if (price is! num ||
        totalRooms is! int ||
        availableRooms is! int ||
        json['id'] is! String ||
        (ownerId != null && ownerId is! String) ||
        json['name'] is! String ||
        json['address_area'] is! String ||
        json['created_at'] is! String) {
      throw const FormatException('Data kos dari Supabase tidak lengkap');
    }
    if (totalRooms <= 0 || availableRooms < 0 || availableRooms > totalRooms) {
      throw const FormatException('Jumlah kamar dari Supabase tidak valid');
    }

    final facilitiesValue = json['facilities'];
    final facilities = facilitiesValue is List
        ? facilitiesValue.whereType<String>().toList(growable: false)
        : <String>[];

    final status = json['status'];
    final expectedStatus = availableRooms == 0 ? 'Penuh' : 'Tersedia';
    if (status != expectedStatus) {
      throw const FormatException('Status kos dari Supabase tidak valid');
    }
    final createdAt = DateTime.tryParse(json['created_at'] as String);
    if (createdAt == null) {
      throw const FormatException('Tanggal kos dari Supabase tidak valid');
    }

    return Kos(
      id: json['id'] as String,
      ownerId: ownerId as String?,
      name: json['name'] as String,
      addressArea: json['address_area'] as String,
      priceMonthly: price.toInt(),
      facilities: facilities,
      totalRooms: totalRooms,
      availableRooms: availableRooms,
      status: status is String ? status : '',
      createdAt: createdAt,
    );
  }

  final String id;
  final String? ownerId;
  final String name;
  final String addressArea;
  final int priceMonthly;
  final List<String> facilities;
  final int totalRooms;
  final int availableRooms;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      'name': name,
      'address_area': addressArea,
      'price_monthly': priceMonthly,
      'facilities': facilities,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
