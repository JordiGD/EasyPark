package co.edu.uptc.reservation.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class SpaceClient {
    
    private static final Logger logger = LoggerFactory.getLogger(SpaceClient.class);
    // Usar el nombre del servicio en Docker en lugar de localhost
    private static final String PARKING_SERVICE_URL = "http://easypark-parking:8081";
    
    @Autowired
    private RestTemplate restTemplate;
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    /**
     * Actualiza el estado de un espacio en el servicio de parking
     * @param spaceId ID del espacio
     * @param status AVAILABLE o OCCUPIED
     * @return true si se actualizó exitosamente
     */
    public boolean updateSpaceStatus(Long spaceId, String status) {
        try {
            String url = PARKING_SERVICE_URL + "/api/spaces/" + spaceId + "/status";
            
            // Configurar headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            // El endpoint espera el estado como JSON String
            String jsonBody = "\"" + status + "\"";
            HttpEntity<String> entity = new HttpEntity<>(jsonBody, headers);
            
            restTemplate.put(url, entity);
            
            logger.info("Espacio {} actualizado a estado: {}", spaceId, status);
            return true;
        } catch (Exception e) {
            logger.error("Error al actualizar estado del espacio {}: {}", spaceId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Obtiene el estado actual de un espacio
     * @param spaceId ID del espacio
     * @return Estado del espacio o null si hay error
     */
    public String getSpaceStatus(Long spaceId) {
        try {
            String url = PARKING_SERVICE_URL + "/api/spaces/" + spaceId + "/status";
            String status = restTemplate.getForObject(url, String.class);
            logger.info("Estado del espacio {}: {}", spaceId, status);
            return status;
        } catch (Exception e) {
            logger.error("Error al obtener estado del espacio {}: {}", spaceId, e.getMessage());
            return null;
        }
    }
}
