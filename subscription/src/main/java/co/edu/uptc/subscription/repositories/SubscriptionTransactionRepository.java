package co.edu.uptc.subscription.repositories;

import co.edu.uptc.subscription.models.SubscriptionTransaction;
import co.edu.uptc.subscription.models.TransactionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SubscriptionTransactionRepository extends JpaRepository<SubscriptionTransaction, Long> {
    List<SubscriptionTransaction> findByDriverSubscriptionIdOrderByTransactionDateDesc(Long driverSubscriptionId);
    List<SubscriptionTransaction> findByStatus(TransactionStatus status);
    List<SubscriptionTransaction> findByTransactionDateBetween(LocalDateTime startDate, LocalDateTime endDate);
}
