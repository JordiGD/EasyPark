import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';

class DriverProvider extends ChangeNotifier {
  final DriverService _driverService = DriverService();

  List<Driver> _drivers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Guardar conductor
  Future<bool> saveDriver(Driver driver) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedDriver = await _driverService.saveDriver(driver);
      _drivers.add(savedDriver);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener todos los conductores
  Future<void> getAllDrivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _drivers = await _driverService.getAllDrivers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
