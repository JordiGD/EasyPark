import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/driver.dart';

class DriverService {
  // URL del servidor backend
  static const String baseUrl = 'http://10.0.2.2:8080'; // Emulador Android
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

  /// Login de usuario
  Future<bool> login(String email, String password) async {
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

      return response.statusCode == 200;
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
      final response = await http
          .get(
            Uri.parse('$baseUrl/driver/alldrivers'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
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
