package co.edu.uptc.parking.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ParkingDTO {

    private Long id;
    private Long ownerId;
    private String name;
    private String address;
    private double pricePerHour;
    private boolean availability;
    private double latitude;
    private double longitude;
    private Long totalSpaces;
    private Long occupiedSpaces;
    
}
