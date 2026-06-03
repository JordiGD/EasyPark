package co.edu.uptc.review.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import co.edu.uptc.review.entity.Review;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByParkingId(Long parkingId);

    List<Review> findByDriverId(Long driverId);

    boolean existsByParkingIdAndDriverId(Long parkingId, Long driverId);

    Review findByParkingIdAndDriverId(Long parkingId, Long driverId);
}
