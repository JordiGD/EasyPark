import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  List<Map<String, dynamic>> _notifications = [];
  Map<int, Map<String, dynamic>> _invoices = {};
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _driverService = DriverService();
    _loadAll();
    // Polling cada 10 segundos para actualizar reservas y notificaciones
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadAll());
    // Countdown actualiza la UI cada segundo
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadReservations(), _loadNotifications()]);
  }

  Future<void> _loadReservations() async {
    try {
      final driverId = context.read<DriverProvider>().lastUserID;
      if (driverId == null || driverId == 0) {
        setState(() { _error = 'No se encontró el ID del conductor'; _isLoading = false; });
        return;
      }

      final data = await _driverService.getAllReservations(driverId);
      final reservations = data.map((j) => Reservation.fromJson(j)).toList();

      // Cargar facturas para reservas INVOICED
      final invoiceUpdates = <int, Map<String, dynamic>>{};
      for (final r in reservations) {
        if (r.status == 'INVOICED' && r.id != null) {
          final inv = await _driverService.getInvoiceByReservation(r.id!);
          if (inv != null) invoiceUpdates[r.id!] = inv;
        }
      }

      if (mounted) {
        setState(() {
          _reservations = reservations;
          _invoices = {..._invoices, ...invoiceUpdates};
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Error: ${e.toString()}'; _isLoading = false; });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final driverId = context.read<DriverProvider>().lastUserID;
      if (driverId == null) return;
      final notifs = await _driverService.getUnreadNotifications(driverId);
      if (mounted) setState(() => _notifications = notifs);
    } catch (_) {}
  }

  Future<void> _confirmArrival(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar llegada'),
        content: Text('¿Confirmas que llegaste al espacio #${reservation.spaceId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, confirmar')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final updated = await _driverService.driverConfirmArrival(reservation.id!);
      if (mounted) {
        setState(() {
          _reservations = _reservations.map((r) =>
            r.id == reservation.id ? Reservation.fromJson(updated) : r).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Llegada confirmada. Espera al propietario.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text('¿Cancelar la reserva en el espacio #${reservation.spaceId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _driverService.cancelReservation(reservation.id!);
      await _loadReservations();
      context.read<ParkingProvider>().getAllParkings();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _openPayment(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el link de pago'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markNotificationRead(int id) async {
    await _driverService.markNotificationRead(id);
    setState(() => _notifications.removeWhere((n) => n['id'] == id));
  }

  String _formatDeadlineCountdown(DateTime? deadline) {
    if (deadline == null) return '';
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Plazo vencido';
    final min = diff.inMinutes;
    final sec = diff.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2,'0')} restantes';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE': return Colors.orange;
      case 'DRIVER_CONFIRMED': return Colors.blue;
      case 'OWNER_CONFIRMED': return Colors.purple;
      case 'INVOICED': return Colors.deepOrange;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'EXPIRED': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        elevation: 0,
        actions: [
          // Campana de notificaciones
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _showNotificationsSheet,
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _reservations.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reservations.length,
                        itemBuilder: (_, i) => _buildCard(_reservations[i]),
                      ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _loadAll, child: const Text('Reintentar')),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('No tienes reservas', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Volver al Mapa')),
      ],
    ),
  );

  Widget _buildCard(Reservation reservation) {
    final invoice = _invoices[reservation.id];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(reservation.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Espacio #${reservation.spaceId}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Parqueadero #${reservation.parkingId}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${reservation.statusIcon} ${reservation.statusLabel}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Detalles
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(Icons.schedule, 'Fecha',
                    '${reservation.startTime.day}/${reservation.startTime.month}/${reservation.startTime.year} '
                    '${reservation.startTime.hour.toString().padLeft(2,'0')}:${reservation.startTime.minute.toString().padLeft(2,'0')}'),

                if (reservation.arrivalDeadline != null && reservation.status == 'ACTIVE') ...[
                  const SizedBox(height: 8),
                  _detailRow(
                    Icons.timer,
                    'Tiempo para llegar',
                    _formatDeadlineCountdown(reservation.arrivalDeadline),
                    color: reservation.arrivalDeadline!.isBefore(DateTime.now()) ? Colors.red : Colors.orange,
                  ),
                ],

                if (reservation.driverConfirmedAt != null) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.directions_car, 'Confirmaste llegada',
                      '${reservation.driverConfirmedAt!.hour.toString().padLeft(2,'0')}:${reservation.driverConfirmedAt!.minute.toString().padLeft(2,'0')}',
                      color: Colors.blue),
                ],

                if (reservation.ownerConfirmedAt != null) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.check_circle, 'Propietario confirmó',
                      '${reservation.ownerConfirmedAt!.hour.toString().padLeft(2,'0')}:${reservation.ownerConfirmedAt!.minute.toString().padLeft(2,'0')}',
                      color: Colors.green),
                ],

                if (invoice != null) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.receipt_long, 'Factura',
                      '\$${invoice['amount']} — ${invoice['status']}',
                      color: Colors.deepOrange),
                ],
              ],
            ),
          ),

          // Acciones
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // ACTIVE → confirmar llegada
                if (reservation.status == 'ACTIVE')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.where_to_vote),
                      label: const Text('Confirmar mi llegada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _confirmArrival(reservation),
                    ),
                  ),

                // ACTIVE → también puede cancelar
                if (reservation.status == 'ACTIVE') ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar reserva'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _cancelReservation(reservation),
                    ),
                  ),
                ],

                // DRIVER_CONFIRMED → esperando al propietario
                if (reservation.status == 'DRIVER_CONFIRMED')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Esperando confirmación del propietario...', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),

                // INVOICED → ir al pago
                if (reservation.status == 'INVOICED' && invoice != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Monto a pagar: \$${invoice['amount']}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                        if (invoice['description'] != null) ...[
                          const SizedBox(height: 4),
                          Text(invoice['description'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text('Pagar con MercadoPago'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _openPayment(invoice['paymentUrl']),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(color: Colors.grey[600])),
                TextSpan(
                  text: value,
                  style: TextStyle(color: color, fontWeight: color != null ? FontWeight.w600 : FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _notifications.isEmpty
                    ? const Center(child: Text('Sin notificaciones pendientes', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (_, i) {
                          final n = _notifications[i];
                          return ListTile(
                            leading: const Icon(Icons.notifications, color: Colors.blue),
                            title: Text(n['message'] ?? '', style: const TextStyle(fontSize: 14)),
                            subtitle: n['createdAt'] != null ? Text(n['createdAt'].toString().substring(0, 16)) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await _markNotificationRead(n['id']);
                                setModalState(() {});
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
