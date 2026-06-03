package co.edu.uptc.subscription.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "driver_subscriptions", indexes = {
    @Index(name = "idx_driver_id", columnList = "driver_id"),
    @Index(name = "idx_plan_id", columnList = "plan_id"),
    @Index(name = "idx_parking_id", columnList = "parking_id"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_driver_parking_status", columnList = "driver_id, parking_id, status")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DriverSubscription {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private Long driverId;
    
    @Column(nullable = false)
    private Long parkingId;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "plan_id", nullable = false)
    private SubscriptionPlan plan;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SubscriptionStatus status;
    
    @Column(nullable = false)
    private LocalDateTime startDate;
    
    @Column(nullable = false)
    private LocalDateTime endDate;
    
    @Column(nullable = false)
    private LocalDateTime renewalDate;
    
    @Column(nullable = false)
    private Boolean autoRenew;
    
    @Column(nullable = false)
    private Integer hoursUsedThisMonth;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethod paymentMethod;
    
    @Column(nullable = false)
    private LocalDateTime nextPaymentDate;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) {
            status = SubscriptionStatus.ACTIVE;
        }
        if (hoursUsedThisMonth == null) {
            hoursUsedThisMonth = 0;
        }
        if (autoRenew == null) {
            autoRenew = true;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
