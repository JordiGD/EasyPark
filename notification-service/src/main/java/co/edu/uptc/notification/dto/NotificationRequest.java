package co.edu.uptc.notification.dto;

public class NotificationRequest {
    private String type;
    private Long targetUserId;
    private String role;
    private String message;
    private Long reservationId;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Long getTargetUserId() { return targetUserId; }
    public void setTargetUserId(Long targetUserId) { this.targetUserId = targetUserId; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }
}
