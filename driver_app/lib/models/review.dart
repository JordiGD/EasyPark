class Review {
  final int? id;
  final int parkingId;
  final int driverId;
  final String? driverName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    required this.parkingId,
    required this.driverId,
    this.driverName,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      parkingId: json['parkingId'] ?? json['parking_id'] ?? 0,
      driverId: json['driverId'] ?? json['driver_id'] ?? 0,
      driverName: json['driverName'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parkingId': parkingId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment,
    };
  }
}
