class Reservation {
  final int? id;
  final int driverId;
  final int spaceId;
  final int parkingId;
  final String status;
  final DateTime startTime;
  final DateTime? arrivalDeadline;
  final DateTime? driverConfirmedAt;
  final DateTime? ownerConfirmedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool canOwnerCancel;
  final bool canGenerateInvoice;

  Reservation({
    this.id,
    required this.driverId,
    required this.spaceId,
    required this.parkingId,
    this.status = 'ACTIVE',
    required this.startTime,
    this.arrivalDeadline,
    this.driverConfirmedAt,
    this.ownerConfirmedAt,
    this.createdAt,
    this.updatedAt,
    this.canOwnerCancel = false,
    this.canGenerateInvoice = false,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      driverId: json['driverId'] ?? 0,
      spaceId: json['spaceId'] ?? 0,
      parkingId: json['parkingId'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      startTime: json['startTime'] is String
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      arrivalDeadline: json['arrivalDeadline'] is String
          ? DateTime.parse(json['arrivalDeadline'])
          : null,
      driverConfirmedAt: json['driverConfirmedAt'] is String
          ? DateTime.parse(json['driverConfirmedAt'])
          : null,
      ownerConfirmedAt: json['ownerConfirmedAt'] is String
          ? DateTime.parse(json['ownerConfirmedAt'])
          : null,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : null,
      canOwnerCancel: json['canOwnerCancel'] ?? false,
      canGenerateInvoice: json['canGenerateInvoice'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'spaceId': spaceId,
      'parkingId': parkingId,
      'status': status,
      'startTime': startTime.toIso8601String(),
    };
  }

  bool get isActive => status == 'ACTIVE';
  bool get canConfirmArrival => status == 'ACTIVE';
  bool get hasPendingInvoice => status == 'INVOICED';

  Duration? get timeUntilDeadline {
    if (arrivalDeadline == null) return null;
    return arrivalDeadline!.difference(DateTime.now());
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE': return 'Activa';
      case 'DRIVER_CONFIRMED': return 'Llegada confirmada';
      case 'OWNER_CONFIRMED': return 'Ambos confirmados';
      case 'INVOICED': return 'Factura pendiente';
      case 'COMPLETED': return 'Completada';
      case 'CANCELLED': return 'Cancelada';
      case 'EXPIRED': return 'Expirada';
      default: return status;
    }
  }

  String get statusIcon {
    switch (status) {
      case 'ACTIVE': return '⏳';
      case 'DRIVER_CONFIRMED': return '🚗';
      case 'OWNER_CONFIRMED': return '✅';
      case 'INVOICED': return '🧾';
      case 'COMPLETED': return '💰';
      case 'CANCELLED': return '✗';
      case 'EXPIRED': return '⏰';
      default: return '•';
    }
  }
}
