import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/driver_service.dart';
import '../widgets/custom_text_field.dart';
import '../providers/driver_provider.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _plateController = TextEditingController();

  late int _userID;
  bool _userIDLoaded = false;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_userIDLoaded) {
      // Obtener el userID de los argumentos (si viene de registro)
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        _userID = args;
      } else {
        // Si no viene de argumentos, obtener del provider (usuario logueado)
        final provider = context.read<DriverProvider>();
        _userID = provider.lastUserID ?? 0;
        // Si aún no hay userID, intentar obtener del localStorage del driver logueado
        if (_userID == 0) {
          _errorMessage =
              'No se pudo identificar el usuario. Por favor inicia sesión de nuevo.';
        }
      }
      _userIDLoaded = true;
    }
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _registerVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final vehicleData = {
        'userID': _userID,
        'vehicule': _vehicleTypeController.text.trim(),
        'plate': _plateController.text.trim(),
      };

      final service = DriverService();
      await service.saveVehicle(vehicleData);

      if (mounted) {
        setState(() => _successMessage = '✓ Vehículo registrado exitosamente');

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/drivers-list');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Vehículo'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              const SizedBox(height: 20),
              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrar Vehículo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Vehicle Type
              CustomTextField(
                controller: _vehicleTypeController,
                label: 'Tipo de Vehículo',
                hint: 'Ej. Auto, Moto, Camioneta',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El tipo de vehículo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Plate
              CustomTextField(
                controller: _plateController,
                label: 'Placa del Vehículo',
                hint: 'ABC-1234',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La placa es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Register Button
              Consumer<DriverProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : _registerVehicle,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrar Vehículo',
                            style: TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Skip Registration Button
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context)
                            .pushReplacementNamed('/drivers-list');
                      },
                child: const Text(
                  'Completar después',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
