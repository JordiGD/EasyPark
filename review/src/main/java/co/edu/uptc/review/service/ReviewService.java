package co.edu.uptc.review.service;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import co.edu.uptc.review.client.UserServiceClient;
import co.edu.uptc.review.dto.CreateReviewRequest;
import co.edu.uptc.review.dto.ReviewDTO;
import co.edu.uptc.review.dto.ReviewWithUserDTO;
import co.edu.uptc.review.dto.UpdateReviewRequest;
import co.edu.uptc.review.entity.Review;
import co.edu.uptc.review.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final UserServiceClient userServiceClient;

    public ReviewWithUserDTO createReview(CreateReviewRequest request) {
        // Si ya existe una reseña del mismo usuario para el mismo parqueadero, actualizarla (upsert)
        if (reviewRepository.existsByParkingIdAndDriverId(request.getParkingId(), request.getDriverId())) {
            Review existing = reviewRepository.findByParkingIdAndDriverId(request.getParkingId(), request.getDriverId());
            if (request.getRating() != null) {
                existing.setRating(request.getRating());
            }
            if (request.getComment() != null) {
                existing.setComment(request.getComment());
            }
            // Intentar actualizar el nombre del usuario si es posible
            try {
                var user = userServiceClient.getUserById(request.getDriverId());
                if (user != null) {
                    existing.setDriverName(user.getName());
                }
            } catch (Exception e) {
                // Ignorar fallo al obtener user
            }

            Review saved = reviewRepository.save(existing);
            return mapToDTOWithUser(saved);
        }

        Review review = new Review();
        review.setParkingId(request.getParkingId());
        review.setDriverId(request.getDriverId());
        review.setRating(request.getRating());
        review.setComment(request.getComment());

        // Intentar obtener el nombre del usuario y persistirlo con la reseña
        try {
            var user = userServiceClient.getUserById(request.getDriverId());
            if (user != null) {
                review.setDriverName(user.getName());
            }
        } catch (Exception e) {
            // No bloquear la creación si falla el user-service
            review.setDriverName("Usuario #" + request.getDriverId());
        }

        Review saved = reviewRepository.save(review);
        return mapToDTOWithUser(saved);
    }

    public ReviewDTO getReviewById(Long id) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Review not found with id: " + id));
        return mapToDTO(review);
    }

    public List<ReviewDTO> getReviewsByParking(Long parkingId) {
        return reviewRepository.findByParkingId(parkingId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<ReviewDTO> getReviewsByDriver(Long driverId) {
        return reviewRepository.findByDriverId(driverId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<ReviewDTO> getAllReviews() {
        return reviewRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<ReviewWithUserDTO> getAllReviewsWithUser() {
        return reviewRepository.findAll().stream()
                .map(this::mapToDTOWithUser)
                .collect(Collectors.toList());
    }

    public List<ReviewWithUserDTO> getReviewsByParkingWithUser(Long parkingId) {
        return reviewRepository.findByParkingId(parkingId).stream()
                .map(this::mapToDTOWithUser)
                .collect(Collectors.toList());
    }

    public ReviewDTO updateReview(Long id, UpdateReviewRequest request) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Review not found with id: " + id));

        if (request.getRating() != null) {
            review.setRating(request.getRating());
        }
        if (request.getComment() != null) {
            review.setComment(request.getComment());
        }

        Review updated = reviewRepository.save(review);
        return mapToDTO(updated);
    }

    public void deleteReview(Long id, Long driverId) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Review not found with id: " + id));
        
        // Solo el driver propietario de la reseña puede eliminarla
        if (!review.getDriverId().equals(driverId)) {
            throw new IllegalArgumentException("No tienes permiso para eliminar esta reseña. Solo el driver propietario puede hacerlo.");
        }
        
        reviewRepository.deleteById(id);
    }

    public double getAverageRatingByParking(Long parkingId) {
        List<Review> reviews = reviewRepository.findByParkingId(parkingId);
        if (reviews.isEmpty()) {
            return 0.0;
        }
        double total = reviews.stream().mapToDouble(Review::getRating).sum();
        return total / reviews.size();
    }

    private ReviewDTO mapToDTO(Review review) {
        return new ReviewDTO(
                review.getId(),
                review.getParkingId(),
                review.getDriverId(),
                review.getRating(),
                review.getComment(),
                review.getCreatedAt(),
                review.getUpdatedAt());
    }

    private ReviewWithUserDTO mapToDTOWithUser(Review review) {
        String driverName = review.getDriverName();
        if (driverName == null || driverName.isBlank()) {
            try {
                var user = userServiceClient.getUserById(review.getDriverId());
                driverName = user != null ? user.getName() : "Usuario #" + review.getDriverId();
            } catch (Exception e) {
                driverName = "Usuario #" + review.getDriverId();
            }
        }

        return ReviewWithUserDTO.builder()
                .id(review.getId())
                .parkingId(review.getParkingId())
                .driverId(review.getDriverId())
                .driverName(driverName)
                .rating(review.getRating())
                .comment(review.getComment())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .build();
    }
}
