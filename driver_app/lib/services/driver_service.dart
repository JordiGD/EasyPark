import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/driver.dart';
import '../models/parking.dart';
import '../models/space.dart';

class DriverService {
  // URL del servidor backend
  static const String baseUrl = 'http://localhost:8080'; // User Service
  static const String parkingApiUrl =
      'http://localhost:8081'; // Parking Service
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
}
