package co.edu.uptc.driver.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserDTO {

    private Long userID;
    private String name;
    private String phoneNumber;
    private String email;
    private String password;
    private String role;
    private LocalDateTime createdAt;
    
}
