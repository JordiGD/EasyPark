package co.edu.uptc.parking.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateParkingRequest {
    
    private Long ownerId;
    private String name;
    private String address;  // Dirección simple: "Cra 5 #7-32"
    private String city;     // "Tunja"
    private String department; // "Boyacá"
    private String country;  // "CO"
    private double pricePerHour;
    private boolean availability;
    
}
