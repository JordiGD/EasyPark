class Space {
  final int? spaceID;
  final int parkingID;
  final String spaceNumber;
  final String status; // "AVAILABLE" o "OCCUPIED"
  final String? description;

  Space({
    this.spaceID,
    required this.parkingID,
    required this.spaceNumber,
    required this.status,
    this.description,
  });

  // Convertir JSON a Space
  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      // Aceptar tanto 'id' como 'spaceID' del JSON
      spaceID: json['spaceID'] ?? json['id'],
      parkingID: json['parkingID'] ?? json['parkingId'] ?? 0,
      spaceNumber: json['spaceNumber'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      description: json['description'],
    );
  }

  // Convertir Space a JSON
  Map<String, dynamic> toJson() {
    return {
      'spaceID': spaceID,
      'parkingID': parkingID,
      'spaceNumber': spaceNumber,
      'status': status,
      'description': description,
    };
  }

  // Verificar si está disponible
  bool get isAvailable => status == 'AVAILABLE';

  // Obtener ícono basado en estado
  String get statusIcon => isAvailable ? '✓ Disponible' : '✗ Ocupado';
}
