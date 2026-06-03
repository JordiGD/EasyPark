import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../models/driver.dart';
import '../providers/subscription_provider.dart';
import '../providers/driver_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  void _loadSubscriptionData() {
    final driverProvider = context.read<DriverProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    final driverId = driverProvider.lastUserID ?? 0;
    if (driverId > 0) {
      subscriptionProvider.loadAvailablePlans();
      subscriptionProvider.loadDriverSubscriptions(driverId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Suscripciones'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Tabs
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabButton(
                        'Planes',
                        0,
                        subscriptionProvider,
                        context,
                      ),
                      _buildTabButton(
                        'Mi Suscripción',
                        1,
                        subscriptionProvider,
                        context,
                      ),
                      _buildTabButton(
                        'Historial',
                        2,
                        subscriptionProvider,
                        context,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Tab Content
                if (_selectedTabIndex == 0)
                  _buildPlansTab(subscriptionProvider),
                if (_selectedTabIndex == 1)
                  _buildActiveSubscriptionTab(subscriptionProvider),
                if (_selectedTabIndex == 2)
                  _buildHistoryTab(subscriptionProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    int index,
    SubscriptionProvider provider,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  _selectedTabIndex == index ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _selectedTabIndex == index ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPlansTab(SubscriptionProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.availablePlans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No hay planes disponibles'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          provider.availablePlans.length,
          (index) => _buildPlanCard(provider.availablePlans[index], provider),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionProvider provider) {
    final driverProvider = context.read<DriverProvider>();
    final driverId = driverProvider.lastUserID ?? 0;
    final isActive =
        provider.driverSubscriptions.any((sub) => sub.planId == plan.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Activo',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${plan.monthlyPrice.toStringAsFixed(2)}/mes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${plan.discountPercentage}% descuento',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (plan.monthlyHours != null)
                      Text(
                        '${plan.monthlyHours}h/mes',
                        style: const TextStyle(fontSize: 12),
                      )
                    else
                      const Text(
                        'Ilimitado',
                        style: TextStyle(fontSize: 12),
                      ),
                    if (plan.maxDailyHours != null)
                      Text(
                        'Máx: ${plan.maxDailyHours}h/día',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectPlan(plan, driverId, provider),
                  child: const Text('Suscribirse'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectPlan(
      SubscriptionPlan plan, int driverId, SubscriptionProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String paymentMethod = 'CREDIT_CARD';
        bool autoRenew = true;

        return AlertDialog(
          title: const Text('Confirmar Suscripción'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Plan: ${plan.name}'),
                  Text('Precio: \$${plan.monthlyPrice}'),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: paymentMethod,
                    onChanged: (String? newValue) {
                      setState(() {
                        paymentMethod = newValue ?? 'CREDIT_CARD';
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'CREDIT_CARD',
                          child: Text('Tarjeta de Crédito')),
                      DropdownMenuItem(
                          value: 'BANK_ACCOUNT',
                          child: Text('Transferencia Bancaria')),
                      DropdownMenuItem(
                          value: 'WALLET', child: Text('Billetera Digital')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Renovación automática'),
                    value: autoRenew,
                    onChanged: (bool? newValue) {
                      setState(() {
                        autoRenew = newValue ?? true;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final parkingId = plan.parkingId ?? 1;
                await provider.createSubscription(
                  driverId: driverId,
                  parkingId: parkingId,
                  planId: plan.id,
                  paymentMethod: paymentMethod,
                  autoRenew: autoRenew,
                );
                _loadSubscriptionData();
              },
              child: const Text('Suscribirse'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveSubscriptionTab(SubscriptionProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.driverSubscriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No tienes suscripciones activas',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: const Text('Ver Planes'),
            ),
          ],
        ),
      );
    }

    final sub = provider.driverSubscriptions.first;
    final daysLeft = sub.endDate.difference(DateTime.now()).inDays;
    final progressPercentage = sub.hoursUsedThisMonth /
        (sub.planName.contains('VIP') || sub.planName.contains('Premium')
            ? 200
            : 40);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.planName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sub.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sub.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Estado:', sub.status),
                  _buildInfoRow('Horas usadas:', '${sub.hoursUsedThisMonth}h'),
                  _buildInfoRow('Próxima renovación:',
                      sub.renewalDate.toString().split(' ')[0]),
                  _buildInfoRow('Métodopago:', sub.paymentMethod),
                  _buildInfoRow(
                      'Renovación automática:', sub.autoRenew ? 'Sí' : 'No'),
                  const SizedBox(height: 16),
                  if (daysLeft >= 0)
                    Text(
                      'Vence en $daysLeft días',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progressPercentage.clamp(0.0, 1.0),
                    minHeight: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    await provider.renewSubscription(sub.id);
                    _loadSubscriptionData();
                  },
                  child: const Text('Renovar Ahora'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancelar Suscripción'),
                        content:
                            const Text('¿Estás seguro de que deseas cancelar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await provider.cancelSubscription(sub.id);
                      _loadSubscriptionData();
                    }
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(SubscriptionProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.driverSubscriptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No hay historial de suscripciones'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          provider.driverSubscriptions.length,
          (index) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.driverSubscriptions[index].planName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                              provider.driverSubscriptions[index].status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.driverSubscriptions[index].status,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Del ${provider.driverSubscriptions[index].startDate.toString().split(' ')[0]} al ${provider.driverSubscriptions[index].endDate.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXPIRED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      case 'PAUSED':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
