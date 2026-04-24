class Reservation {
  final int? id;
  final int driverId;
  final int spaceId;
  final int parkingId;
  final String status; // ACTIVE, COMPLETED, CANCELLED, EXPIRED
  final DateTime startTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reservation({
    this.id,
    required this.driverId,
    required this.spaceId,
    required this.parkingId,
    this.status = 'ACTIVE',
    required this.startTime,
    this.createdAt,
    this.updatedAt,
  });

  // Convertir JSON a Reservation
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      driverId: json['driverId'] ?? 0,
      spaceId: json['spaceId'] ?? 0,
      parkingId: json['parkingId'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      startTime: json['startTime'] is String
          ? DateTime.parse(json['startTime'])
          : json['startTime'] ?? DateTime.now(),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : json['createdAt'],
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : json['updatedAt'],
    );
  }

  // Convertir Reservation a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'spaceId': spaceId,
      'parkingId': parkingId,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Estado legible
  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        return 'Activa';
      case 'COMPLETED':
        return 'Completada';
      case 'CANCELLED':
        return 'Cancelada';
      case 'EXPIRED':
        return 'Expirada';
      default:
        return status;
    }
  }

  // Ícono de estado
  String get statusIcon {
    switch (status) {
      case 'ACTIVE':
        return '🟢';
      case 'COMPLETED':
        return '✓';
      case 'CANCELLED':
        return '✗';
      case 'EXPIRED':
        return '⏰';
      default:
        return '•';
    }
  }
}
