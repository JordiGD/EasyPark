package co.edu.uptc.reservation.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
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
    private static final String NOTIFICATION_SERVICE_URL = "http://easypark-notification:8086";

    @Autowired
    private RestTemplate restTemplate;

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

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            restTemplate.postForObject(NOTIFICATION_SERVICE_URL + "/api/notifications/send", entity, Void.class);
        } catch (Exception e) {
            logger.warn("No se pudo enviar notificación: {}", e.getMessage());
        }
    }
}
