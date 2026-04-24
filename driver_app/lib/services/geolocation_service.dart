import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../models/parking.dart';

class GeolocationService {
  final String baseUrl;

  GeolocationService({this.baseUrl = 'http://localhost:8081'});

  // Obtener ubicación actual del usuario
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  // Obtener todos los parqueaderos
  Future<List<Parking>> getAllParkings() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/api/parkings/map/all'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al obtener parqueaderos');
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((parking) => Parking.fromJson(parking)).toList();
      } else {
        throw Exception(
            'Error al obtener parqueaderos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAllParkings: $e');
      return [];
    }
  }

  // Obtener parqueaderos cercanos (dentro de un radio)
  Future<List<Parking>> getNearbyParkings({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse(
          '$baseUrl/api/parkings/nearby?latitude=$latitude&longitude=$longitude&radiusKm=$radiusKm',
        ),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al obtener parqueaderos cercanos');
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((parking) => Parking.fromJson(parking)).toList();
      } else {
        throw Exception(
            'Error al obtener parqueaderos cercanos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getNearbyParkings: $e');
      return [];
    }
  }

  // Calcular distancia entre dos puntos (Haversine)
  static double calculateDistance(LatLng from, LatLng to) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(to.latitude - from.latitude);
    final double dLon = _degreesToRadians(to.longitude - from.longitude);
    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(from.latitude)) *
            math.cos(_degreesToRadians(to.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
