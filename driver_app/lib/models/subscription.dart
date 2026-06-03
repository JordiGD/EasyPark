import 'dart:convert';

class SubscriptionPlan {
  final int id;
  final int? parkingId;
  final String name;
  final String description;
  final double monthlyPrice;
  final int discountPercentage;
  final int? maxDailyHours;
  final int? monthlyHours;
  final List<String> features;
  final bool isActive;

  SubscriptionPlan({
    required this.id,
    this.parkingId,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.discountPercentage,
    this.maxDailyHours,
    this.monthlyHours,
    required this.features,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    List<String> parseFeatures(dynamic featuresData) {
      if (featuresData is String) {
        try {
          List<dynamic> decoded = jsonDecode(featuresData);
          return decoded.map((e) => e.toString()).toList();
        } catch (e) {
          return [];
        }
      } else if (featuresData is List) {
        return featuresData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return SubscriptionPlan(
      id: json['id'] ?? 0,
      parkingId: json['parkingId'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: json['discountPercentage'] ?? 0,
      maxDailyHours: json['maxDailyHours'],
      monthlyHours: json['monthlyHours'],
      features: parseFeatures(json['features']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parkingId': parkingId,
      'name': name,
      'description': description,
      'monthlyPrice': monthlyPrice,
      'discountPercentage': discountPercentage,
      'maxDailyHours': maxDailyHours,
      'monthlyHours': monthlyHours,
      'features': features,
      'isActive': isActive,
    };
  }
}

class DriverSubscription {
  final int id;
  final int driverId;
  final int parkingId;
  final int planId;
  final String planName;
  final String status; // ACTIVE, EXPIRED, CANCELLED, PAUSED
  final DateTime startDate;
  final DateTime endDate;
  final DateTime renewalDate;
  final bool autoRenew;
  final int hoursUsedThisMonth;
  final String paymentMethod;
  final DateTime nextPaymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverSubscription({
    required this.id,
    required this.driverId,
    required this.parkingId,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.renewalDate,
    required this.autoRenew,
    required this.hoursUsedThisMonth,
    required this.paymentMethod,
    required this.nextPaymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverSubscription.fromJson(Map<String, dynamic> json) {
    return DriverSubscription(
      id: json['id'] ?? 0,
      driverId: json['driverId'] ?? 0,
      parkingId: json['parkingId'] ?? 0,
      planId: json['planId'] ?? 0,
      planName: json['planName'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      renewalDate: DateTime.parse(
          json['renewalDate'] ?? DateTime.now().toIso8601String()),
      autoRenew: json['autoRenew'] ?? true,
      hoursUsedThisMonth: json['hoursUsedThisMonth'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'CREDIT_CARD',
      nextPaymentDate: DateTime.parse(
          json['nextPaymentDate'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'parkingId': parkingId,
      'planId': planId,
      'planName': planName,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'renewalDate': renewalDate.toIso8601String(),
      'autoRenew': autoRenew,
      'hoursUsedThisMonth': hoursUsedThisMonth,
      'paymentMethod': paymentMethod,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SubscriptionDiscount {
  final int driverId;
  final int discountPercentage;
  final bool hasActiveSubscription;
  final String planName;

  SubscriptionDiscount({
    required this.driverId,
    required this.discountPercentage,
    required this.hasActiveSubscription,
    required this.planName,
  });

  factory SubscriptionDiscount.fromJson(Map<String, dynamic> json) {
    return SubscriptionDiscount(
      driverId: json['driverId'] ?? 0,
      discountPercentage: json['discountPercentage'] ?? 0,
      hasActiveSubscription: json['hasActiveSubscription'] ?? false,
      planName: json['planName'] ?? 'Sin suscripción',
    );
  }
}
