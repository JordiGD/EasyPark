package co.edu.uptc.review.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateReviewRequest {

    private Long parkingId;
    private Long driverId;
    private Integer rating;
    private String comment;
}
