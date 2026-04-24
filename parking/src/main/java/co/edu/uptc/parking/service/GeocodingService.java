package co.edu.uptc.parking.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.google.maps.GeoApiContext;
import com.google.maps.GeocodingApi;
import com.google.maps.model.GeocodingResult;
import com.google.maps.model.AddressComponent;
import com.google.maps.model.AddressComponentType;

import co.edu.uptc.parking.dto.GeocodingResponse;

@Service
public class GeocodingService {
    
    @Value("${geocoding.api-key:}")
    private String apiKey;
    
    @Value("${geocoding.timeout:5000}")
    private long timeout;
    
    /**
     * Geocodifica una dirección para obtener coordenadas y componentes geográficos
     * @param address Dirección a geocodificar (ej: "Cra 5 #7-32, Tunja, Boyacá, Colombia")
     * @return GeocodingResponse con lat, lon, ciudad, departamento, país
     */
    public GeocodingResponse geocodeAddress(String address) {
        GeocodingResponse response = new GeocodingResponse();
        
        // Validación básica
        if (address == null || address.trim().isEmpty()) {
            response.setSuccess(false);
            response.setErrorMessage("La dirección no puede estar vacía");
            return response;
        }
        
        try {
            // Crear contexto con Google Maps API
            GeoApiContext context = new GeoApiContext.Builder()
                    .apiKey(apiKey)
                    .build();
            
            // Realizar geocodificación sincrónica
            GeocodingResult[] results = GeocodingApi.geocode(context, address).await();
            
            if (results == null || results.length == 0) {
                response.setSuccess(false);
                response.setErrorMessage("No se encontraron resultados para la dirección proporcionada");
                return response;
            }
            
            // Usar el primer resultado
            GeocodingResult result = results[0];
            
            // Extraer valores
            response.setLatitude(result.geometry.location.lat);
            response.setLongitude(result.geometry.location.lng);
            response.setFormattedAddress(result.formattedAddress);
            
            // Parsear componentes de dirección
            parseAddressComponents(result.addressComponents, response);
            
            response.setSuccess(true);
            
            // Cerrar contexto
            context.shutdown();
            
        } catch (Exception e) {
            response.setSuccess(false);
            response.setErrorMessage("Error en geocodificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
    
    /**
     * Extrae componentes de dirección (ciudad, departamento, país) del resultado
     */
    private void parseAddressComponents(AddressComponent[] components, GeocodingResponse response) {
        for (AddressComponent component : components) {
            for (AddressComponentType type : component.types) {
                switch (type) {
                    case LOCALITY:
                        // Ciudad
                        response.setCity(component.longName);
                        break;
                    case ADMINISTRATIVE_AREA_LEVEL_1:
                        // Departamento/Provincia
                        response.setDepartment(component.shortName);
                        break;
                    case COUNTRY:
                        // País
                        response.setCountry(component.shortName);
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
}
