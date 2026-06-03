package co.edu.uptc.subscription.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionPlanDTO {
    private Long id;
    private Long parkingId;
    private String name;
    private String description;
    private BigDecimal monthlyPrice;
    private Integer discountPercentage;
    private Integer maxDailyHours;
    private Integer monthlyHours;
    private String features;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
