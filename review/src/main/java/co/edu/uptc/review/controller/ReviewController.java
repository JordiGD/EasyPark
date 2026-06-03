package co.edu.uptc.review.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import co.edu.uptc.review.dto.CreateReviewRequest;
import co.edu.uptc.review.dto.ReviewDTO;
import co.edu.uptc.review.dto.ReviewWithUserDTO;
import co.edu.uptc.review.dto.UpdateReviewRequest;
import co.edu.uptc.review.service.ReviewService;
import lombok.RequiredArgsConstructor;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    public ResponseEntity<ReviewWithUserDTO> createReview(@RequestBody CreateReviewRequest request) {
        ReviewWithUserDTO review = reviewService.createReview(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(review);
    }

    @GetMapping
    public ResponseEntity<List<ReviewDTO>> getAllReviews() {
        return ResponseEntity.ok(reviewService.getAllReviews());
    }

    @GetMapping("/all")
    public ResponseEntity<List<ReviewWithUserDTO>> getAllReviewsWithUser() {
        return ResponseEntity.ok(reviewService.getAllReviewsWithUser());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReviewDTO> getReviewById(@PathVariable Long id) {
        return ResponseEntity.ok(reviewService.getReviewById(id));
    }

    @GetMapping("/parking/{parkingId}")
    public ResponseEntity<List<ReviewWithUserDTO>> getReviewsByParking(@PathVariable Long parkingId) {
        return ResponseEntity.ok(reviewService.getReviewsByParkingWithUser(parkingId));
    }

    @GetMapping("/parking/{parkingId}/average")
    public ResponseEntity<Double> getAverageRatingByParking(@PathVariable Long parkingId) {
        return ResponseEntity.ok(reviewService.getAverageRatingByParking(parkingId));
    }

    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<ReviewDTO>> getReviewsByDriver(@PathVariable Long driverId) {
        return ResponseEntity.ok(reviewService.getReviewsByDriver(driverId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ReviewDTO> updateReview(@PathVariable Long id, @RequestBody UpdateReviewRequest request) {
        return ResponseEntity.ok(reviewService.updateReview(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable Long id, @RequestParam Long driverId) {
        reviewService.deleteReview(id, driverId);
        return ResponseEntity.noContent().build();
    }
}
