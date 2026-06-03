package co.edu.uptc.subscription.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionDiscountDTO {
    private Long driverId;
    private Integer discountPercentage;
    private Boolean hasActiveSubscription;
    private String planName;
}
