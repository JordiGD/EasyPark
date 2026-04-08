package co.edu.uptc.parking.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SpaceDTO {
    
    private Long spaceId;
    private Long parkingId;
    private String spaceNumber;
    private String status;
}
