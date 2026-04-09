import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking.dart';
import '../models/space.dart';
import '../services/driver_service.dart';

class ParkingDetailScreen extends StatefulWidget {
  final Parking? parking;

  const ParkingDetailScreen({Key? key, this.parking}) : super(key: key);

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  late DriverService _driverService;
  List<Space> _spaces = [];
  bool _isLoadingSpaces = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _driverService = DriverService();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    final parkingArg = ModalRoute.of(context)?.settings.arguments as Parking?;
    final currentParking = widget.parking ?? parkingArg;

    if (currentParking?.id == null) return;

    setState(() {
      _isLoadingSpaces = true;
      _errorMessage = null;
    });

    try {
      final spaces =
          await _driverService.getSpacesByParking(currentParking!.id!);
      setState(() {
        _spaces = spaces;
        _isLoadingSpaces = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingSpaces = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingArg = ModalRoute.of(context)?.settings.arguments as Parking?;
    final currentParking = widget.parking ?? parkingArg;

    if (currentParking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Parqueadero')),
        body: const Center(
          child: Text('Error: No se encontró el parqueadero'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Parqueadero'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con info principal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentParking.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentParking.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(currentParking.phone),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ocupación
            const Text(
              'Disponibilidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Espacios disponibles:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${currentParking.availableSpaces} / ${currentParking.totalSpaces}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: currentParking.availableSpaces > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 1 - (currentParking.occupancyPercentage / 100),
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentParking.availableSpaces > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ocupación: ${currentParking.occupancyPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentParking.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Precio por hora
            const Text(
              'Tarifa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio por Hora:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${currentParking.pricePerHour.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de acción
            if (currentParking.availableSpaces > 0) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reserva de espacio en ${currentParking.name}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Reservar Espacio'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.block),
                  label: const Text('Sin Espacios Disponibles'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
