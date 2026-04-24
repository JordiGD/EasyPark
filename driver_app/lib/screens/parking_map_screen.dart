import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/geolocation_provider.dart';
import '../providers/parking_provider.dart';
import '../providers/driver_provider.dart';
import '../models/parking.dart';
import '../models/space.dart';
import '../services/driver_service.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({Key? key}) : super(key: key);

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  late GoogleMapController mapController;
  Parking? _selectedParking;

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
    mapController.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng location) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  void _moveToCurrentLocation(LatLng location) {
    _moveToLocation(location);
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
            // Información
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.local_parking,
                        size: 32, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      '${parking.availableSpaces}/${parking.totalSpaces}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Espacios', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.attach_money,
                        size: 32, color: Colors.green),
                    const SizedBox(height: 8),
                    Text(
                      '\$${parking.pricePerHour.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Por hora', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      parking.availableSpaces > 0
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 32,
                      color: parking.availableSpaces > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      parking.availableSpaces > 0 ? 'Disponible' : 'Lleno',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: parking.availableSpaces > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Botones de acción
            if (parking.availableSpaces > 0)
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
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.block),
                  label: const Text('Sin Espacios Disponibles'),
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
}
