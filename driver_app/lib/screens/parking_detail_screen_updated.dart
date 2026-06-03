import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking.dart';
import '../models/space.dart';
import '../models/subscription.dart';
import '../services/driver_service.dart';
import '../providers/driver_provider.dart';
import '../providers/subscription_provider.dart';

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
  bool _isLoadingSubscription = false;
  String? _errorMessage;
  DriverSubscription? _activeSubscription;

  @override
  void initState() {
    super.initState();
    _driverService = DriverService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSpaces();
      _loadSubscriptionInfo();
    });
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

  Future<void> _loadSubscriptionInfo() async {
    final parkingArg = ModalRoute.of(context)?.settings.arguments as Parking?;
    final currentParking = widget.parking ?? parkingArg;

    if (currentParking?.id == null) return;

    final driverId = context.read<DriverProvider>().lastUserID;
    if (driverId == null) return;

    setState(() {
      _isLoadingSubscription = true;
    });

    try {
      final subscription = await _driverService.getActiveSubscription(
        driverId,
        currentParking!.id!,
      );
      setState(() {
        _activeSubscription = subscription;
        _isLoadingSubscription = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSubscription = false;
      });
    }
  }

  Future<void> _showSubscriptionPlans(
      BuildContext context, Parking parking) async {
    final driverId = context.read<DriverProvider>().lastUserID;
    if (driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: SubscriptionPlansSheet(
          parking: parking,
          driverId: driverId,
          onSubscriptionCreated: () {
            _loadSubscriptionInfo();
          },
        ),
      ),
    );
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
            // Header
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

            // Suscripción Activa (si existe)
            if (_activeSubscription != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu Suscripción en este Parqueadero',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.green.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _activeSubscription!.planName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Activa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Horas usadas este mes: ${_activeSubscription!.hoursUsedThisMonth}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Renovación: ${_activeSubscription!.renewalDate.split('T')[0]}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Disponibilidad
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

            // Tarifa
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

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: currentParking.availableSpaces > 0
                        ? () => _showSubscriptionPlans(context, currentParking)
                        : null,
                    icon: const Icon(Icons.card_membership),
                    label: const Text('Ver Planes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: currentParking.availableSpaces > 0
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Reserva de espacio en ${currentParking.name}',
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Reservar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlansSheet extends StatefulWidget {
  final Parking parking;
  final int driverId;
  final VoidCallback onSubscriptionCreated;

  const SubscriptionPlansSheet({
    Key? key,
    required this.parking,
    required this.driverId,
    required this.onSubscriptionCreated,
  }) : super(key: key);

  @override
  State<SubscriptionPlansSheet> createState() => _SubscriptionPlansSheetState();
}

class _SubscriptionPlansSheetState extends State<SubscriptionPlansSheet> {
  late DriverService _driverService;
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _errorMessage;
  SubscriptionPlan? _selectedPlan;
  String _selectedPaymentMethod = 'CREDIT_CARD';
  bool _autoRenew = true;

  @override
  void initState() {
    super.initState();
    _driverService = DriverService();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plans = await _driverService.getSubscriptionPlans();
      setState(() {
        _plans = plans;
        if (plans.isNotEmpty) {
          _selectedPlan = plans[0];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar planes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createSubscription() async {
    if (_selectedPlan == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _driverService.createSubscription(
        driverId: widget.driverId,
        parkingId: widget.parking.id!,
        planId: _selectedPlan!.id!,
        paymentMethod: _selectedPaymentMethod,
        autoRenew: _autoRenew,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Suscripción creada exitosamente!')),
        );
        widget.onSubscriptionCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Planes en ${widget.parking.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 20),
        // Contenido
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Planes disponibles
                          ..._plans.map((plan) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPlan = plan;
                                  });
                                },
                                child: Card(
                                  color: _selectedPlan?.id == plan.id
                                      ? Colors.blue.withOpacity(0.1)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              plan.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Radio<SubscriptionPlan>(
                                              value: plan,
                                              groupValue: _selectedPlan,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedPlan = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          plan.description,
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${plan.monthlyPrice.toStringAsFixed(2)}/mes',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              'Descuento: ${plan.discountPercentage}%',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20),
                          // Opciones de pago
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Método de Pago',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButton<String>(
                                    value: _selectedPaymentMethod,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'CREDIT_CARD',
                                        child: Text('Tarjeta de Crédito'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'BANK_ACCOUNT',
                                        child: Text('Cuenta Bancaria'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'WALLET',
                                        child: Text('Billetera Digital'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentMethod =
                                            value ?? 'CREDIT_CARD';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _autoRenew,
                                        onChanged: (value) {
                                          setState(() {
                                            _autoRenew = value ?? false;
                                          });
                                        },
                                      ),
                                      const Expanded(
                                        child: Text('Renovación automática'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
        // Botón de acción
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPlan != null && !_isLoading
                  ? _createSubscription
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Suscribirse a \$${_selectedPlan?.monthlyPrice.toStringAsFixed(2) ?? "0"}/mes',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
