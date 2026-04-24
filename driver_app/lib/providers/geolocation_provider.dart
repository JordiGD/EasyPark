import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/parking.dart';
import '../services/geolocation_service.dart';

class GeolocationProvider with ChangeNotifier {
  final GeolocationService _geoService;

  LatLng? _currentLocation;
  List<Parking> _parkings = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _selectedRadius = 5.0;

  GeolocationProvider({GeolocationService? geoService})
      : _geoService = geoService ?? GeolocationService();

  // Getters
  LatLng? get currentLocation => _currentLocation;
  List<Parking> get parkings => _parkings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get selectedRadius => _selectedRadius;

  // Obtener ubicación actual y cargar parqueaderos cercanos
  Future<void> initializeLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final location = await _geoService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        await _loadNearbyParkings();
      } else {
        // Si no obtiene ubicación, carga todos los parqueaderos
        await loadAllParkings();
        _errorMessage = 'No se pudo obtener la ubicación actual';
      }
    } catch (e) {
      _errorMessage = 'Error al inicializar: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar parqueaderos cercanos
  Future<void> _loadNearbyParkings() async {
    try {
      if (_currentLocation != null) {
        _parkings = await _geoService.getNearbyParkings(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
          radiusKm: _selectedRadius,
        );
      }
    } catch (e) {
      _errorMessage = 'Error al cargar parqueaderos cercanos: $e';
      print(_errorMessage);
    }
    notifyListeners();
  }

  // Cargar todos los parqueaderos
  Future<void> loadAllParkings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parkings = await _geoService.getAllParkings();
    } catch (e) {
      _errorMessage = 'Error al cargar parqueaderos: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar radio de búsqueda
  Future<void> updateSearchRadius(double radius) async {
    _selectedRadius = radius;
    if (_currentLocation != null) {
      await _loadNearbyParkings();
    } else {
      notifyListeners();
    }
  }

  // Refrescar ubicación actual y parqueaderos
  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final location = await _geoService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        await _loadNearbyParkings();
      }
    } catch (e) {
      _errorMessage = 'Error al refrescar ubicación: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calcular distancia a un parqueadero
  double getDistanceToParkings(Parking parking) {
    if (_currentLocation == null) return 0;
    return GeolocationService.calculateDistance(
      _currentLocation!,
      LatLng(parking.latitude, parking.longitude),
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
