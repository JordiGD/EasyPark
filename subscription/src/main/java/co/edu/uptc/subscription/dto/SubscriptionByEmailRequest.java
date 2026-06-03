package co.edu.uptc.subscription.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionByEmailRequest {
    private String driverEmail;
    private Long parkingId;
    private Long planId;
    private String paymentMethod;
    private Boolean autoRenew;
}
