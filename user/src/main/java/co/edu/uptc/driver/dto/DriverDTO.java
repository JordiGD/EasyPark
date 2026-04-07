package co.edu.uptc.driver.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DriverDTO {

    private Long driverID;
    private Long userID;
    private String vehicule;
    private String plate;
    
}
