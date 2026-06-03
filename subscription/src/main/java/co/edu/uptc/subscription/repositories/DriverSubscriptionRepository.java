package co.edu.uptc.subscription.repositories;

import co.edu.uptc.subscription.models.DriverSubscription;
import co.edu.uptc.subscription.models.SubscriptionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DriverSubscriptionRepository extends JpaRepository<DriverSubscription, Long> {
    Optional<DriverSubscription> findByDriverIdAndParkingIdAndStatus(Long driverId, Long parkingId, SubscriptionStatus status);
    Optional<DriverSubscription> findByDriverIdAndParkingId(Long driverId, Long parkingId);
    List<DriverSubscription> findByDriverIdAndParkingIdOrderByCreatedAtDesc(Long driverId, Long parkingId);
    List<DriverSubscription> findByDriverIdOrderByCreatedAtDesc(Long driverId);
    List<DriverSubscription> findByParkingIdAndStatus(Long parkingId, SubscriptionStatus status);
    List<DriverSubscription> findByParkingIdOrderByCreatedAtDesc(Long parkingId);
    List<DriverSubscription> findByStatus(SubscriptionStatus status);
    List<DriverSubscription> findByStatusAndAutoRenewTrue(SubscriptionStatus status);
}
