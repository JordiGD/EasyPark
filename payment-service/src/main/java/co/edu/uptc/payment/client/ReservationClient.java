package co.edu.uptc.payment.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class ReservationClient {

    private static final Logger logger = LoggerFactory.getLogger(ReservationClient.class);

    @Value("${app.reservation-service-url}")
    private String reservationServiceUrl;

    private final RestTemplate restTemplate;

    public ReservationClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void markAsInvoiced(Long reservationId) {
        try {
            restTemplate.put(reservationServiceUrl + "/api/reservations/" + reservationId + "/invoiced", null);
        } catch (Exception e) {
            logger.warn("No se pudo marcar reserva {} como INVOICED: {}", reservationId, e.getMessage());
        }
    }

    public void markAsCompleted(Long reservationId) {
        try {
            restTemplate.put(reservationServiceUrl + "/api/reservations/" + reservationId + "/complete", null);
        } catch (Exception e) {
            logger.warn("No se pudo marcar reserva {} como COMPLETED: {}", reservationId, e.getMessage());
        }
    }
}
