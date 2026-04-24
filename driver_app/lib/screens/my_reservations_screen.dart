import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation.dart';
import '../providers/driver_provider.dart';
import '../providers/parking_provider.dart';
import '../services/driver_service.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({Key? key}) : super(key: key);

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late DriverService _driverService;
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _driverService = DriverService();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final driverId = context.read<DriverProvider>().lastUserID;
      if (driverId == null || driverId == 0) {
        setState(() {
          _error = 'No se encontró el ID del conductor';
          _isLoading = false;
        });
        return;
      }

      final reservationsData =
          await _driverService.getActiveReservations(driverId);
      final reservations =
          reservationsData.map((json) => Reservation.fromJson(json)).toList();

      setState(() {
        _reservations = reservations;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    // Confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: Text(
          '¿Seguro que deseas cancelar la reserva en el espacio ${reservation.spaceId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (reservation.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID de reserva no válido')),
        );
        return;
      }

      await _driverService.cancelReservation(reservation.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva cancelada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar reservas y actualizar espacios disponibles
      await _loadReservations();
      // Refrescar el ParkingProvider para actualizar espacios disponibles en el mapa
      context.read<ParkingProvider>().getAllParkings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadReservations,
                          child: const Text('Intentar de Nuevo'),
                        ),
                      ],
                    ),
                  )
                : _reservations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes reservas activas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Volver al Mapa'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = _reservations[index];
                          return _buildReservationCard(reservation);
                        },
                      ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final timeColor = _getTimeColor(reservation.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          // Header con estado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espacio #${reservation.spaceId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Parqueadero #${reservation.parkingId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reservation.statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha y hora
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fecha: ${reservation.startTime.day}/${reservation.startTime.month}/${reservation.startTime.year}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: timeColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hora: ${reservation.startTime.hour.toString().padLeft(2, '0')}:${reservation.startTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: timeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ID de reserva
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID Reserva: ${reservation.id}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón de cancelar
          if (reservation.status == 'ACTIVE')
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel_presentation),
                  label: const Text('Cancelar Reserva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _cancelReservation(reservation),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Esta reserva ya no está activa',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      case 'EXPIRED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTimeColor(DateTime startTime) {
    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.inHours < 0) {
      return Colors.red; // Ya pasó
    } else if (difference.inHours < 1) {
      return Colors.orange; // Menos de 1 hora
    } else {
      return Colors.green; // Tiempo disponible
    }
  }
}
