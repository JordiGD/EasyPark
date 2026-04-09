class Parking {
  final int? id;
  final int ownerId;
  final String name;
  final String address;
  final String phone;
  final String description;
  final int totalSpaces;
  final int occupiedSpaces;
  final double pricePerHour;

  Parking({
    this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.totalSpaces,
    required this.occupiedSpaces,
    required this.pricePerHour,
  });

  // Convertir JSON a Parking
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      ownerId: json['ownerId'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      totalSpaces: json['totalSpaces'] ?? 0,
      occupiedSpaces: json['occupiedSpaces'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
    );
  }

  // Convertir Parking a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'totalSpaces': totalSpaces,
      'occupiedSpaces': occupiedSpaces,
      'pricePerHour': pricePerHour,
    };
  }

  // Calcular espacios disponibles
  int get availableSpaces => totalSpaces - occupiedSpaces;

  // Calcular porcentaje de ocupación
  double get occupancyPercentage {
    if (totalSpaces == 0) return 0;
    return (occupiedSpaces / totalSpaces) * 100;
  }
}
