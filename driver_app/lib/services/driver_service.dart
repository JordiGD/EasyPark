import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/driver.dart';
import '../models/parking.dart';
import '../models/review.dart';
import '../models/space.dart';
import '../models/subscription.dart';

class DriverService {
  // URL del servidor backend
  static const String baseUrl = 'http://localhost:8080'; // User Service
  static const String parkingApiUrl =
      'http://localhost:8081'; // Parking Service
  static const String subscriptionApiUrl =
      'http://localhost:8084'; // Subscription Service
  // Para emulador Android: 'http://10.0.2.2:8080'
  // Para dispositivo físico: 'http://192.168.X.X:8080'

  // ==================== USER ENDPOINTS ====================

  /// Registrar nuevo usuario (conductor)
  Future<Map<String, dynamic>> saveUser(Map<String, dynamic> userData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/saveUser'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al guardar usuario: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en saveUser: $e');
    }
  }

  /// Actualizar usuario existente
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/updateUser'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar usuario: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en updateUser: $e');
    }
  }

  /// Login de usuario - retorna user info con userID
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200) {
        // Obtener información del usuario
        final userResponse = await http.get(
          Uri.parse('$baseUrl/user/email/$email'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout al conectar'),
        );

        if (userResponse.statusCode == 200) {
          return jsonDecode(userResponse.body);
        } else {
          throw Exception('Error al obtener datos del usuario');
        }
      } else {
        throw Exception('Login fallido');
      }
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  // ==================== DRIVER ENDPOINTS ====================

  /// Registrar vehículo
  Future<Map<String, dynamic>> saveVehicle(
    Map<String, dynamic> vehicleData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/driver/saveVehicule'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(vehicleData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al guardar vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en saveVehicle: $e');
    }
  }

  /// Actualizar vehículo
  Future<Map<String, dynamic>> updateVehicle(
    Map<String, dynamic> vehicleData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/driver/updateVehicule'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(vehicleData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en updateVehicle: $e');
    }
  }

  // ==================== PARKING ENDPOINTS ====================

  /// Obtener todos los parqueaderos disponibles
  Future<List<Parking>> getAllParkings() async {
    try {
      final response = await http.get(
        Uri.parse('$parkingApiUrl/api/parkings'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener parqueaderos');
      }
    } catch (e) {
      throw Exception('Error en getAllParkings: $e');
    }
  }

  /// Obtener detalles de un parqueadero
  Future<Parking> getParkingById(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('$parkingApiUrl/api/parkings/$parkingId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return Parking.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener parqueadero: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getParkingById: $e');
    }
  }

  /// Obtener status/ocupación de un parqueadero
  Future<Map<String, dynamic>> getParkingStatus(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('$parkingApiUrl/api/parkings/$parkingId/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getParkingStatus: $e');
    }
  }

  // ==================== REVIEW ENDPOINTS ====================

  /// URL del Review Service
  static const String reviewApiUrl = 'http://localhost:8083';

  /// Obtener reseñas de un parqueadero
  Future<List<Review>> getReviewsByParking(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('$reviewApiUrl/api/reviews/parking/$parkingId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener reseñas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getReviewsByParking: $e');
    }
  }

  /// Obtener calificación promedio de un parqueadero
  Future<double> getAverageRatingByParking(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('$reviewApiUrl/api/reviews/parking/$parkingId/average'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is num) {
          return decoded.toDouble();
        }
        return double.parse(response.body);
      } else {
        throw Exception(
            'Error al obtener calificación promedio: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getAverageRatingByParking: $e');
    }
  }

  /// Crear reseña de un parqueadero
  Future<Review> createReview({
    required int parkingId,
    required int driverId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$reviewApiUrl/api/reviews'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'parkingId': parkingId,
              'driverId': driverId,
              'rating': rating,
              'comment': comment,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty) {
          return Review(
            parkingId: parkingId,
            driverId: driverId,
            rating: rating,
            comment: comment,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            return Review.fromJson(decoded);
          }
          if (decoded is List && decoded.isNotEmpty) {
            return Review.fromJson(decoded.first as Map<String, dynamic>);
          }

          return Review(
            parkingId: parkingId,
            driverId: driverId,
            rating: rating,
            comment: comment,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } catch (_) {
          return Review(
            parkingId: parkingId,
            driverId: driverId,
            rating: rating,
            comment: comment,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } else {
        throw Exception('Error al crear reseña: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en createReview: $e');
    }
  }

  // ==================== SPACE ENDPOINTS ====================

  /// Obtener espacios de un parqueadero
  Future<List<Space>> getSpacesByParking(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('$parkingApiUrl/api/spaces/parking/$parkingId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Space.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener espacios');
      }
    } catch (e) {
      throw Exception('Error en getSpacesByParking: $e');
    }
  }

  /// Obtener estado de un espacio
  Future<String> getSpaceStatus(int spaceId) async {
    try {
      final response = await http.get(
        Uri.parse('$parkingApiUrl/api/spaces/$spaceId/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Error al obtener estado del espacio');
      }
    } catch (e) {
      throw Exception('Error en getSpaceStatus: $e');
    }
  }

  // ==================== LEGACY ENDPOINTS ====================

  /// Guardar conductor (legacy)
  Future<Driver> saveDriver(Driver driver) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/driver/savedriver'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(driver.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 201) {
        return Driver.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al guardar conductor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener todos los conductores (legacy)
  Future<List<Driver>> getAllDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/driver/alldrivers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener conductores');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== RESERVATION ENDPOINTS ====================

  /// Crear nueva reserva
  /// URL: http://localhost:8082/api/reservations
  Future<Map<String, dynamic>> createReservation({
    required int driverId,
    required int spaceId,
    required int parkingId,
    required DateTime startTime,
  }) async {
    try {
      final reservationData = {
        'driverId': driverId,
        'spaceId': spaceId,
        'parkingId': parkingId,
        'startTime': startTime.toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('http://localhost:8082/api/reservations'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reservationData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear reserva: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en createReservation: $e');
    }
  }

  /// Obtener reservas activas de un conductor
  Future<List<Map<String, dynamic>>> getActiveReservations(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8082/api/reservations/driver/$driverId/active'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener reservas');
      }
    } catch (e) {
      throw Exception('Error en getActiveReservations: $e');
    }
  }

  /// Cancelar una reserva
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:8082/api/reservations/$reservationId/cancel'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cancelar reserva: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en cancelReservation: $e');
    }
  }

  /// Obtener todas las reservas de un conductor (todos los estados)
  Future<List<Map<String, dynamic>>> getAllReservations(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8082/api/reservations/driver/$driverId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Timeout'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      throw Exception('Error al obtener reservas: ${response.body}');
    } catch (e) {
      throw Exception('Error en getAllReservations: $e');
    }
  }

  /// Conductor confirma su llegada al parqueadero
  Future<Map<String, dynamic>> driverConfirmArrival(int reservationId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8082/api/reservations/$reservationId/driver-confirm'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Timeout'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al confirmar llegada: ${response.body}');
    } catch (e) {
      throw Exception('Error en driverConfirmArrival: $e');
    }
  }

  /// Obtener factura por reserva
  Future<Map<String, dynamic>?> getInvoiceByReservation(int reservationId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8085/api/invoices/reservation/$reservationId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Timeout'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener notificaciones no leídas del conductor
  Future<List<Map<String, dynamic>>> getUnreadNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8086/api/notifications/user/$userId/unread'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Timeout'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Marcar notificación como leída
  Future<void> markNotificationRead(int notificationId) async {
    try {
      await http.put(
        Uri.parse('http://localhost:8086/api/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5), onTimeout: () => throw Exception('Timeout'));
    } catch (_) {}
  }

  // ==================== SUBSCRIPTION ENDPOINTS ====================

  /// Obtener planes de suscripción disponibles globales (deprecated, usar getPlansByParking en su lugar)
  @Deprecated('Use getPlansByParking instead')
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$subscriptionApiUrl/api/subscriptions/plans'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => SubscriptionPlan.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener planes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getSubscriptionPlans: $e');
    }
  }

  /// Obtener planes de suscripción disponibles para un parqueadero específico
  Future<List<SubscriptionPlan>> getPlansByParking(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$subscriptionApiUrl/api/subscriptions/plans/parking/$parkingId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => SubscriptionPlan.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener planes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getPlansByParking: $e');
    }
  }

  /// Obtener suscripción activa del conductor en un parqueadero específico
  Future<DriverSubscription?> getActiveSubscription(
      int driverId, int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$subscriptionApiUrl/api/subscriptions/driver/$driverId/active?parkingId=$parkingId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return DriverSubscription.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null; // No active subscription
      } else {
        throw Exception('Error al obtener suscripción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getActiveSubscription: $e');
    }
  }

  /// Obtener todas las suscripciones del conductor
  Future<List<DriverSubscription>> getDriverSubscriptions(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$subscriptionApiUrl/api/subscriptions/driver/$driverId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => DriverSubscription.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al obtener suscripciones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getDriverSubscriptions: $e');
    }
  }

  /// Obtener descuento aplicable para el conductor en un parqueadero específico
  Future<SubscriptionDiscount?> getApplicableDiscount(
      int driverId, int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$subscriptionApiUrl/api/subscriptions/driver/$driverId/discount?parkingId=$parkingId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return SubscriptionDiscount.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener descuento: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en getApplicableDiscount: $e');
    }
  }

  /// Crear nueva suscripción en un parqueadero específico
  Future<DriverSubscription> createSubscription({
    required int driverId,
    required int parkingId,
    required int planId,
    required String paymentMethod,
    required bool autoRenew,
  }) async {
    try {
      final subscriptionData = {
        'driverId': driverId,
        'parkingId': parkingId,
        'planId': planId,
        'paymentMethod': paymentMethod,
        'autoRenew': autoRenew,
      };

      final response = await http
          .post(
            Uri.parse('$subscriptionApiUrl/api/subscriptions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(subscriptionData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout al conectar'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DriverSubscription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear suscripción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en createSubscription: $e');
    }
  }

  /// Renovar suscripción
  Future<DriverSubscription> renewSubscription(int subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$subscriptionApiUrl/api/subscriptions/$subscriptionId/renew'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return DriverSubscription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al renovar suscripción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en renewSubscription: $e');
    }
  }

  /// Cancelar suscripción
  Future<DriverSubscription> cancelSubscription(int subscriptionId) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$subscriptionApiUrl/api/subscriptions/$subscriptionId/cancel'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return DriverSubscription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al cancelar suscripción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en cancelSubscription: $e');
    }
  }

  /// Pausar suscripción
  Future<DriverSubscription> pauseSubscription(int subscriptionId) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$subscriptionApiUrl/api/subscriptions/$subscriptionId/pause'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar'),
      );

      if (response.statusCode == 200) {
        return DriverSubscription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al pausar suscripción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en pauseSubscription: $e');
    }
  }
}
