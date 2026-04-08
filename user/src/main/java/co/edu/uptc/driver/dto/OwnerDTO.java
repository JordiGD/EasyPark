package co.edu.uptc.driver.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OwnerDTO {

    private Long ownerID;
    private Long userID;
    private List<Long> parkingIds;
           
}
