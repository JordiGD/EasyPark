import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/geolocation_provider.dart';
import '../providers/parking_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/parking.dart';
import '../models/review.dart';
import '../models/space.dart';
import '../models/subscription.dart';
import '../screens/parking_reviews_screen.dart';
import '../screens/subscription_screen.dart';
import '../services/driver_service.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({Key? key}) : super(key: key);

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  GoogleMapController? mapController;
  Parking? _selectedParking;
  final DriverService _driverService = DriverService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeolocationProvider>().initializeLocation();
      context.read<ParkingProvider>().getAllParkings();
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  void _moveToCurrentLocation(LatLng location) {
    _moveToLocation(location);
  }

  Future<void> _showParkingDetails(Parking parking) async {
    final BuildContext parentContext = context;
    List<Review> reviews = [];
    double averageRating = 0.0;
    String? reviewError;

    try {
      reviews = await _driverService.getReviewsByParking(parking.id!);
      averageRating =
          await _driverService.getAverageRatingByParking(parking.id!);
    } catch (e) {
      reviewError = e.toString();
    }

    if (!mounted) return;

    bool sheetMounted = true;

    final sheetFuture = showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: StatefulBuilder(
          builder: (context, setStateSheet) {
            Future<void> _submitReview(
                int rating, String comment, int driverId) async {
              try {
                final newReview = await _driverService.createReview(
                  parkingId: parking.id!,
                  driverId: driverId,
                  rating: rating,
                  comment: comment.trim().isEmpty ? null : comment.trim(),
                );

                double newAverage = averageRating;
                try {
                  newAverage = await _driverService
                      .getAverageRatingByParking(parking.id!);
                } catch (_) {
                  // Mantener el promedio actual si el servicio no responde.
                }

                if (sheetMounted) {
                  setStateSheet(() {
                    reviews.insert(0, newReview);
                    averageRating = newAverage;
                    reviewError = null;
                  });
                }

                if (!mounted) return;
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Reseña enviada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text('Error al enviar reseña: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              parking.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              parking.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoColumn(
                                icon: Icons.local_parking,
                                label: 'Espacios',
                                value:
                                    '${parking.availableSpaces}/${parking.totalSpaces}',
                              ),
                              _buildInfoColumn(
                                icon: Icons.attach_money,
                                label: 'Por hora',
                                value:
                                    '\$${parking.pricePerHour.toStringAsFixed(2)}',
                              ),
                              _buildInfoColumn(
                                icon: parking.availableSpaces > 0
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                label: 'Estado',
                                value: parking.availableSpaces > 0
                                    ? 'Disponible'
                                    : 'Lleno',
                                color: parking.availableSpaces > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                averageRating > 0
                                    ? averageRating.toStringAsFixed(1)
                                    : 'Sin calificación',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${reviews.length} reseñas)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (reviewError != null) ...[
                            Text(
                              'Error cargando reseñas: $reviewError',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const Text(
                            'Reseñas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Text(
                                        averageRating > 0
                                            ? averageRating.toStringAsFixed(1)
                                            : 'Sin calificación',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${reviews.length} reseñas)',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Solo se muestra el promedio aquí. Usa el botón para ver todas las reseñas.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          parentContext,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ParkingReviewsScreen(
                                              parking: parking,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.list),
                                      label: const Text('Ver reseñas'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final driverId = parentContext
                                    .read<DriverProvider>()
                                    .lastUserID;
                                if (driverId == null) {
                                  ScaffoldMessenger.of(parentContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error: Usuario no identificado'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context);
                                _showAddReviewDialog(
                                    parking, driverId, _submitReview);
                              },
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Dejar reseña'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showReservationDialog(parking);
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Reservar Espacio'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showSubscriptionPlans(parking);
                              },
                              icon: const Icon(Icons.card_membership),
                              label: const Text('Suscribirse'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    sheetFuture.whenComplete(() {
      sheetMounted = false;
    });

    await sheetFuture;
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    Color color = Colors.blue,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showAddReviewDialog(
    Parking parking,
    int driverId,
    Future<void> Function(int rating, String comment, int driverId) onSubmit,
  ) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dejar una reseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calificación'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    selectedRating = starIndex;
                    (context as Element).markNeedsBuild();
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comentario',
                hintText: 'Escribe tu opinión',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await onSubmit(selectedRating, commentController.text, driverId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReservationDialog(Parking parking) async {
    final driverService = DriverService();
    final driverId = context.read<DriverProvider>().lastUserID;

    if (driverId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }

    try {
      // Cargar espacios disponibles
      final spaces = await driverService.getSpacesByParking(parking.id!);
      final availableSpaces = spaces.where((s) => s.isAvailable).toList();

      if (!mounted) return;

      if (availableSpaces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No hay espacios disponibles en este momento')),
        );
        return;
      }

      // Mostrar diálogo para seleccionar espacio
      showDialog<Space>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Seleccionar Espacio'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableSpaces.length,
              itemBuilder: (context, index) {
                final space = availableSpaces[index];
                return ListTile(
                  title: Text('Espacio ${space.spaceNumber}'),
                  subtitle: Text(space.description ?? ''),
                  leading: const Icon(Icons.local_parking, color: Colors.green),
                  onTap: () => Navigator.pop(context, space),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ).then((selectedSpace) async {
        if (selectedSpace != null && mounted) {
          await _createReservation(
            parking,
            selectedSpace,
            driverId,
            driverService,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _createReservation(
    Parking parking,
    Space space,
    int driverId,
    DriverService driverService,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procesando reserva...')),
      );

      final result = await driverService.createReservation(
        driverId: driverId,
        spaceId: space.spaceID ?? 0,
        parkingId: parking.id ?? 0,
        startTime: DateTime.now(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Reserva confirmada en ${parking.name}!\nEspacio: ${space.spaceNumber}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navegar a pantalla de reservas activas o detalles
      if (mounted) {
        // Aquí podrías navegar a una pantalla de reservas activas
        Navigator.pushNamed(context, '/parking-map');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Set<Marker> _buildMarkers(
      GeolocationProvider geoProvider, ParkingProvider parkingProvider) {
    Set<Marker> markers = {};

    // Marcador de ubicación actual
    if (geoProvider.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: geoProvider.currentLocation!,
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // Marcadores de parqueaderos
    for (var parking in parkingProvider.parkings) {
      markers.add(
        Marker(
          markerId: MarkerId('parking_${parking.id}'),
          position: LatLng(parking.latitude, parking.longitude),
          infoWindow: InfoWindow(
            title: parking.name,
            snippet:
                '${parking.availableSpaces} espacios disponibles - \$${parking.pricePerHour.toStringAsFixed(2)}/hora',
          ),
          onTap: () {
            setState(() {
              _selectedParking = parking;
            });
            _moveToLocation(LatLng(parking.latitude, parking.longitude));
            _showParkingDetails(parking);
          },
          icon: _getMarkerIcon(parking),
        ),
      );
    }

    return markers;
  }

  BitmapDescriptor _getMarkerIcon(Parking parking) {
    if (parking.availableSpaces > 0) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  Set<Circle> _buildCircles(GeolocationProvider provider) {
    Set<Circle> circles = {};

    if (provider.currentLocation != null) {
      circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: provider.currentLocation!,
          radius: provider.selectedRadius * 1000,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }

    return circles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Parqueaderos'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'edit-driver') {
                Navigator.pushNamed(context, '/edit-user');
              } else if (value == 'edit-vehicle') {
                Navigator.pushNamed(context, '/vehicle-register');
              } else if (value == 'reservations') {
                Navigator.pushNamed(context, '/my-reservations');
              } else if (value == 'subscriptions') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              } else if (value == 'logout') {
                context.read<DriverProvider>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'edit-driver',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Editar Conductor'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'edit-vehicle',
                child: Row(
                  children: [
                    Icon(Icons.directions_car, size: 20),
                    SizedBox(width: 12),
                    Text('Editar Vehículo'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'reservations',
                child: Row(
                  children: [
                    Icon(Icons.bookmark, size: 20),
                    SizedBox(width: 12),
                    Text('Mis Reservas'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'subscriptions',
                child: Row(
                  children: [
                    Icon(Icons.card_membership, size: 20),
                    SizedBox(width: 12),
                    Text('Gestionar Suscripciones'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Consumer2<GeolocationProvider, ParkingProvider>(
        builder: (context, geoProvider, parkingProvider, _) {
          if (geoProvider.isLoading && geoProvider.currentLocation == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Obteniendo tu ubicación...'),
                ],
              ),
            );
          }

          if (geoProvider.errorMessage != null &&
              geoProvider.currentLocation == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    geoProvider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      geoProvider.initializeLocation();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Mapa ocupa 70% del espacio
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) {
                        mapController = controller;
                        if (geoProvider.currentLocation != null) {
                          _moveToCurrentLocation(geoProvider.currentLocation!);
                        }
                      },
                      initialCameraPosition: CameraPosition(
                        target: geoProvider.currentLocation ??
                            const LatLng(5.5161, -73.3625), // Tunja por defecto
                        zoom: 14.0,
                      ),
                      markers: _buildMarkers(geoProvider, parkingProvider),
                      circles: _buildCircles(geoProvider),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                    // FloatingActionButton para actualizar ubicación
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          if (geoProvider.currentLocation != null) {
                            _moveToCurrentLocation(
                                geoProvider.currentLocation!);
                          }
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
              // Panel inferior con lista de parqueaderos ocupa 30%
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle de arrastre
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Título
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.local_parking),
                            const SizedBox(width: 8),
                            Text(
                              '${parkingProvider.parkings.length} parqueaderos',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lista de parqueaderos - con GestureDetector para absorber gestos
                      Expanded(
                        child: GestureDetector(
                          onVerticalDragUpdate: (_) {
                            // Absorber el gesto vertical para evitar que se propague al mapa
                          },
                          onVerticalDragStart: (_) {},
                          onVerticalDragEnd: (_) {},
                          child: parkingProvider.parkings.isEmpty
                              ? const Center(
                                  child:
                                      Text('No hay parqueaderos disponibles'),
                                )
                              : ListView.builder(
                                  itemCount: parkingProvider.parkings.length,
                                  itemBuilder: (context, index) {
                                    final parking =
                                        parkingProvider.parkings[index];
                                    final isSelected =
                                        _selectedParking?.id == parking.id;
                                    return ListTile(
                                      selected: isSelected,
                                      selectedTileColor:
                                          Colors.blue.withOpacity(0.1),
                                      title: Text(parking.name),
                                      subtitle: Text(parking.address),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${parking.pricePerHour}/h',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${parking.availableSpaces}/${parking.totalSpaces}',
                                            style: TextStyle(
                                              color: parking.availableSpaces > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedParking = parking;
                                        });
                                        _moveToLocation(LatLng(parking.latitude,
                                            parking.longitude));
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSubscriptionPlans(Parking parking) async {
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
            // Recargar datos si es necesario
          },
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
      final plans = await _driverService.getPlansByParking(widget.parking.id!);
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
