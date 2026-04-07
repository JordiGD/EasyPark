import 'package:flutter/material.dart';
import '../services/driver_service.dart';
import '../widgets/custom_text_field.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> driverData;

  const VehicleRegistrationScreen({Key? key, required this.driverData})
    : super(key: key);

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _seatsController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _licenseController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _seatsController.dispose();
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
        'license': _licenseController.text,
        'brand': _brandController.text,
        'model': _modelController.text,
        'color': _colorController.text,
        'year': int.parse(_yearController.text),
        'seats': int.parse(_seatsController.text),
        // Añadir datos del conductor
        ...widget.driverData,
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
              Card(
                elevation: 0,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Vehículo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completa todos los datos de tu vehículo',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // License Plate
              CustomTextField(
                controller: _licenseController,
                label: 'Placa del Vehículo',
                hint: 'ABC-1234',
                icon: Icons.directions_car,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La placa es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Brand
              CustomTextField(
                controller: _brandController,
                label: 'Marca',
                hint: 'Toyota, Hyundai, etc.',
                icon: Icons.factory,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La marca es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Model
              CustomTextField(
                controller: _modelController,
                label: 'Modelo',
                hint: 'Corolla, i10, etc.',
                icon: Icons.model_training,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El modelo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Color
              CustomTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'Negro, Blanco, etc.',
                icon: Icons.palette,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El color es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Year and Seats in Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _yearController,
                      label: 'Año',
                      hint: '2023',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Requerido';
                        }
                        final year = int.tryParse(value ?? '');
                        if (year == null || year < 1980 || year > 2100) {
                          return 'Año inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _seatsController,
                      label: 'Asientos',
                      hint: '4',
                      icon: Icons.event_seat,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Requerido';
                        }
                        final seats = int.tryParse(value ?? '');
                        if (seats == null || seats < 1 || seats > 9) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),

              // Success Message
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _registerVehicle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Registrar Vehículo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/drivers-list');
                      },
                child: const Text('Omitir por ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
