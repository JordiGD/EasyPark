import 'package:flutter/material.dart';
import '../models/parking.dart';
import '../models/review.dart';
import '../services/driver_service.dart';

class ParkingReviewsScreen extends StatefulWidget {
  const ParkingReviewsScreen({Key? key, required this.parking})
      : super(key: key);

  final Parking parking;

  @override
  State<ParkingReviewsScreen> createState() => _ParkingReviewsScreenState();
}

class _ParkingReviewsScreenState extends State<ParkingReviewsScreen> {
  final DriverService _driverService = DriverService();
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (widget.parking.id == null) {
      setState(() {
        _errorMessage = 'ID de parqueadero no válido';
        _isLoading = false;
      });
      return;
    }

    try {
      final reviews =
          await _driverService.getReviewsByParking(widget.parking.id!);
      final average =
          await _driverService.getAverageRatingByParking(widget.parking.id!);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _averageRating = average;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas - ${widget.parking.name}'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No se pudieron cargar las reseñas.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReviews,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 28),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _averageRating > 0
                                        ? _averageRating.toStringAsFixed(1)
                                        : 'Sin calificación',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_reviews.length} reseñas',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _reviews.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aún no hay reseñas. Sé el primero en dejar una.',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                itemCount: _reviews.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemBuilder: (context, index) {
                                  final review = _reviews[index];
                                  final displayName = review.driverName ??
                                      'Usuario #${review.driverId}';
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[50],
                                      child: Text(
                                        review.rating.toString(),
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    title: Text(
                                      review.comment ?? 'Sin comentario',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(displayName),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
