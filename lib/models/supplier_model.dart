class Supplier {
  String? id; // Gunakan String untuk ID
  String name;
  String address;
  String phone;
  double? latitude;
  double? longitude;

  Supplier({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static Supplier fromFirestore(String id, Map<String, dynamic> data) {
    return Supplier(
      id: id,
      name: data['name'],
      address: data['address'],
      phone: data['phone'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}
