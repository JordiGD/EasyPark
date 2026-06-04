package co.edu.uptc.payment.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Component
public class NotificationClient {

    private static final Logger logger = LoggerFactory.getLogger(NotificationClient.class);

    @Value("${app.notification-service-url}")
    private String notificationServiceUrl;

    private final RestTemplate restTemplate;

    public NotificationClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void sendNotification(String type, Long targetUserId, String role, String message, Long reservationId) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> body = new HashMap<>();
            body.put("type", type);
            body.put("targetUserId", targetUserId);
            body.put("role", role);
            body.put("message", message);
            body.put("reservationId", reservationId);

            restTemplate.postForObject(
                    notificationServiceUrl + "/api/notifications/send",
                    new HttpEntity<>(body, headers),
                    Void.class);
        } catch (Exception e) {
            logger.warn("No se pudo enviar notificación: {}", e.getMessage());
        }
    }
}
