import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/driver_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final DriverService _driverService = DriverService();

  // Variables de estado
  List<SubscriptionPlan> _availablePlans = [];
  DriverSubscription? _activeSubscription;
  List<DriverSubscription> _driverSubscriptions = [];
  SubscriptionDiscount? _applicableDiscount;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Getters
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  DriverSubscription? get activeSubscription => _activeSubscription;
  List<DriverSubscription> get driverSubscriptions => _driverSubscriptions;
  SubscriptionDiscount? get applicableDiscount => _applicableDiscount;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  /// Cargar todos los planes activos
  Future<void> loadAvailablePlans() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _availablePlans = await _driverService.getSubscriptionPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar planes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar suscripción activa del conductor en un parqueadero específico
  Future<void> loadActiveSubscription(int driverId, int parkingId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _activeSubscription =
          await _driverService.getActiveSubscription(driverId, parkingId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No hay suscripción activa en este parqueadero';
      _activeSubscription = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar todas las suscripciones del conductor
  Future<void> loadDriverSubscriptions(int driverId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _driverSubscriptions =
          await _driverService.getDriverSubscriptions(driverId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar suscripciones: $e';
      _driverSubscriptions = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nueva suscripción en un parqueadero específico
  Future<void> createSubscription({
    required int driverId,
    required int parkingId,
    required int planId,
    required String paymentMethod,
    required bool autoRenew,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
      notifyListeners();

      await _driverService.createSubscription(
        driverId: driverId,
        parkingId: parkingId,
        planId: planId,
        paymentMethod: paymentMethod,
        autoRenew: autoRenew,
      );

      _successMessage = 'Suscripción creada exitosamente';
      await loadActiveSubscription(driverId, parkingId);
      await loadDriverSubscriptions(driverId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al crear suscripción: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener descuento aplicable en un parqueadero específico
  Future<void> loadApplicableDiscount(int driverId, int parkingId) async {
    try {
      _applicableDiscount =
          await _driverService.getApplicableDiscount(driverId, parkingId);
      notifyListeners();
    } catch (e) {
      _applicableDiscount = null;
      notifyListeners();
    }
  }

  /// Renovar suscripción
  Future<void> renewSubscription(int subscriptionId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
      notifyListeners();

      await _driverService.renewSubscription(subscriptionId);

      _successMessage = 'Suscripción renovada exitosamente';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al renovar suscripción: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancelar suscripción
  Future<void> cancelSubscription(int subscriptionId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
      notifyListeners();

      await _driverService.cancelSubscription(subscriptionId);

      _successMessage = 'Suscripción cancelada';
      _activeSubscription = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cancelar suscripción: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pausar suscripción
  Future<void> pauseSubscription(int subscriptionId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
      notifyListeners();

      await _driverService.pauseSubscription(subscriptionId);

      _successMessage = 'Suscripción pausada';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al pausar suscripción: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpiar mensajes
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}
