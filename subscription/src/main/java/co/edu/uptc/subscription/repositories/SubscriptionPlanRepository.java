package co.edu.uptc.subscription.repositories;

import co.edu.uptc.subscription.models.SubscriptionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SubscriptionPlanRepository extends JpaRepository<SubscriptionPlan, Long> {
    Optional<SubscriptionPlan> findByParkingIdAndNameAndIsActiveTrue(Long parkingId, String name);
    List<SubscriptionPlan> findByParkingIdAndIsActiveTrue(Long parkingId);
    List<SubscriptionPlan> findByParkingId(Long parkingId);
    List<SubscriptionPlan> findByIsActiveTrue();
    Optional<SubscriptionPlan> findByIdAndParkingId(Long id, Long parkingId);
}
