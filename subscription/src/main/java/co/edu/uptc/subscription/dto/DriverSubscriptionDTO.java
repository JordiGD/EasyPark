package co.edu.uptc.subscription.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DriverSubscriptionDTO {
    private Long id;
    private Long driverId;
    private Long parkingId;
    private Long planId;
    private String planName;
    private String status;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private LocalDateTime renewalDate;
    private Boolean autoRenew;
    private Integer hoursUsedThisMonth;
    private String paymentMethod;
    private LocalDateTime nextPaymentDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
