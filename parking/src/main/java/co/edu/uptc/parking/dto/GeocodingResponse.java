package co.edu.uptc.parking.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GeocodingResponse {
    
    private double latitude;
    private double longitude;
    private String city;
    private String department;
    private String country;
    private String formattedAddress;
    private boolean success;
    private String errorMessage;
    
}
