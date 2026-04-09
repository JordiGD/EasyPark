import 'package:flutter/material.dart';
import '../models/parking.dart';
import '../services/driver_service.dart';

class ParkingProvider extends ChangeNotifier {
  final DriverService _driverService = DriverService();

  bool _isLoading = false;
  List<Parking> _parkings = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Parking> get parkings => _parkings;
  String? get errorMessage => _errorMessage;

  Future<void> getAllParkings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parkings = await _driverService.getAllParkings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Parking?> getParkingById(int parkingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final parking = await _driverService.getParkingById(parkingId);
      _isLoading = false;
      notifyListeners();
      return parking;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
