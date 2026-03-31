import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/driver.dart';

class DriverService {
  // URL del servidor backend - Cambiar según tu configuración
  static const String baseUrl = 'http://10.0.2.2:8080'; // Para emulador Android
  // Para dispositivo físico: 'http://TU_IP_LOCAL:8080'

  // Endpoint para guardar conductor
  Future<Driver> saveDriver(Driver driver) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/savedriver'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(driver.toJson()),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al conectar con el servidor');
        },
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

  // Endpoint para obtener todos los conductores
  Future<List<Driver>> getAllDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/driver/alldrivers'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al conectar con el servidor');
        },
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
