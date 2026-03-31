package co.edu.uptc.driver.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DriverDTO {

    private Long driverID;
    private String name;
    private String phoneNumber;
    private String email;
    private String password;
    
}
