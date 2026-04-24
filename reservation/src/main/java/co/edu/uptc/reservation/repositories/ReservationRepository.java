package co.edu.uptc.reservation.repositories;

import co.edu.uptc.reservation.models.Reservation;
import co.edu.uptc.reservation.models.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    
    List<Reservation> findByDriverId(Long driverId);
    
    List<Reservation> findByParkingId(Long parkingId);
    
    List<Reservation> findBySpaceId(Long spaceId);
    
    List<Reservation> findByStatus(ReservationStatus status);
    
    List<Reservation> findByDriverIdAndStatus(Long driverId, ReservationStatus status);
}
