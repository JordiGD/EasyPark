package co.edu.uptc.reservation.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateReservationRequest {
    private Long driverId;
    private Long spaceId;
    private Long parkingId;
    private LocalDateTime startTime;
}
