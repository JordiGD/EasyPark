package co.edu.uptc.parking.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.parking.Mapper.ParkingMapper;
import co.edu.uptc.parking.dto.ParkingDTO;
import co.edu.uptc.parking.dto.GeocodingResponse;
import co.edu.uptc.parking.dto.CreateParkingRequest;
import co.edu.uptc.parking.entity.Parking;
import co.edu.uptc.parking.entity.Space;
import co.edu.uptc.parking.repo.ParkingRepo;
import co.edu.uptc.parking.repo.SpaceRepo;

@Service
public class ParkingService {

    @Autowired
    private ParkingRepo parkingRepo;
    
    @Autowired
    private SpaceRepo spaceRepo;
    
    @Autowired
    private ParkingMapper parkingMapper;
    
    @Autowired
    private GeocodingService geocodingService;

    /**
     * Crea un parqueadero con dirección y componentes geográficos separados
     */
    public ParkingDTO saveParking(CreateParkingRequest request) {
        // Validación básica
        if (request.getAddress() == null || request.getAddress().trim().isEmpty()) {
            throw new IllegalArgumentException("La dirección no puede estar vacía");
        }
        
        Parking parking = new Parking();
        parking.setOwnerId(request.getOwnerId());
        parking.setName(request.getName());
        parking.setAddress(request.getAddress());
        parking.setPricePerHour(request.getPricePerHour());
        parking.setAvailability(request.isAvailability());
        
        System.out.println("[DEBUG] Creating parking with city=" + request.getCity() + 
                          ", department=" + request.getDepartment() + 
                          ", country=" + request.getCountry());
        
        // Modo 1: Si el usuario proporciona TODOS los componentes, usarlos directamente
        boolean hasCity = request.getCity() != null && !request.getCity().trim().isEmpty();
        boolean hasDept = request.getDepartment() != null && !request.getDepartment().trim().isEmpty();
        boolean hasCountry = request.getCountry() != null && !request.getCountry().trim().isEmpty();
        
        if (hasCity && hasDept && hasCountry) {
            System.out.println("[DEBUG] Modo 1: Usando componentes del request");
            parking.setCity(request.getCity().trim());
            parking.setDepartment(request.getDepartment().trim());
            parking.setCountry(request.getCountry().trim());
            
            // Geocodificar solo con dirección para obtener coordenadas
            GeocodingResponse geoResponse = geocodingService.geocodeAddress(request.getAddress());
            
            if (geoResponse.isSuccess()) {
                parking.setLatitude(geoResponse.getLatitude());
                parking.setLongitude(geoResponse.getLongitude());
            } else {
                throw new IllegalArgumentException("No se pudo geocodificar la dirección: " + geoResponse.getErrorMessage());
            }
        } else {
            // Modo 2: Geocodificar con dirección completa para obtener todo
            System.out.println("[DEBUG] Modo 2: Geocodificación completa");
            GeocodingResponse geoResponse = geocodingService.geocodeAddress(request.getAddress());
            
            if (!geoResponse.isSuccess()) {
                throw new IllegalArgumentException("Error en geocodificación: " + geoResponse.getErrorMessage());
            }
            
            parking.setLatitude(geoResponse.getLatitude());
            parking.setLongitude(geoResponse.getLongitude());
            parking.setCity(geoResponse.getCity());
            parking.setDepartment(geoResponse.getDepartment());
            parking.setCountry(geoResponse.getCountry());
        }
        
        Parking savedParking = parkingRepo.save(parking);
        return enrichParkingDTO(parkingMapper.toDTO(savedParking));
    }
    
    /**
     * Sobrecarga para compatibilidad con ParkingDTO (legacy)
     */
    public ParkingDTO saveParkingFromDTO(ParkingDTO parkingDTO) {
        CreateParkingRequest request = new CreateParkingRequest();
        request.setOwnerId(parkingDTO.getOwnerId());
        request.setName(parkingDTO.getName());
        request.setAddress(parkingDTO.getAddress());
        request.setCity(parkingDTO.getCity());
        request.setDepartment(parkingDTO.getDepartment());
        request.setCountry(parkingDTO.getCountry());
        request.setPricePerHour(parkingDTO.getPricePerHour());
        request.setAvailability(parkingDTO.isAvailability());
        
        return saveParking(request);
    }

    public ParkingDTO getParkingById(Long id) {
        Optional<Parking> parking = parkingRepo.findById(id);
        return parking.map(p -> enrichParkingDTO(parkingMapper.toDTO(p))).orElse(null);
    }

    public boolean getStatusParkingById(Long id) {
        Optional<Parking> parking = parkingRepo.findById(id);
        return parking.map(Parking::isAvailability).orElse(false);
    }

    public ParkingDTO updateParking(Long id, ParkingDTO parkingDTO) {
        Optional<Parking> existingParking = parkingRepo.findById(id);
        
        if (existingParking.isPresent()) {
            Parking parking = existingParking.get();
            parking.setOwnerId(parkingDTO.getOwnerId());
            parking.setName(parkingDTO.getName());
            parking.setAddress(parkingDTO.getAddress());
            parking.setPricePerHour(parkingDTO.getPricePerHour());
            parking.setAvailability(parkingDTO.isAvailability());
            
            // Geocodificar la dirección si cambió
            if (!parking.getAddress().equals(parkingDTO.getAddress())) {
                GeocodingResponse geoResponse = geocodingService.geocodeAddress(parkingDTO.getAddress());
                
                if (!geoResponse.isSuccess()) {
                    throw new IllegalArgumentException("Error en geocodificación: " + geoResponse.getErrorMessage());
                }
                
                parking.setLatitude(geoResponse.getLatitude());
                parking.setLongitude(geoResponse.getLongitude());
                parking.setCity(geoResponse.getCity());
                parking.setDepartment(geoResponse.getDepartment());
                parking.setCountry(geoResponse.getCountry());
            } else {
                // Mantener valores anteriores si la dirección no cambió
                parking.setLatitude(parkingDTO.getLatitude());
                parking.setLongitude(parkingDTO.getLongitude());
                parking.setCity(parkingDTO.getCity());
                parking.setDepartment(parkingDTO.getDepartment());
                parking.setCountry(parkingDTO.getCountry());
            }
            
            Parking updatedParking = parkingRepo.save(parking);
            return enrichParkingDTO(parkingMapper.toDTO(updatedParking));
        }
        
        return null;
    }

    public List<ParkingDTO> getParkingByOwnerId(Long ownerId) {
        List<Parking> parkings = parkingRepo.findAll();
        return parkings.stream()
                .filter(parking -> parking.getOwnerId().equals(ownerId))
                .map(p -> enrichParkingDTO(parkingMapper.toDTO(p)))
                .collect(Collectors.toList());
    }

    public List<ParkingDTO> getAllParkings() {
        List<Parking> parkings = parkingRepo.findAll();
        return parkings.stream()
                .map(p -> enrichParkingDTO(parkingMapper.toDTO(p)))
                .collect(Collectors.toList());
    }
    
    // Obtener parqueaderos cercanos (para mapas)
    public List<ParkingDTO> getParkingsNearby(double latitude, double longitude, double radiusKm) {
        List<Parking> allParkings = parkingRepo.findAll();
        double radiusRadians = radiusKm / 6371.0; // Convertir km a radianes
        
        return allParkings.stream()
                .filter(p -> calculateDistance(latitude, longitude, p.getLatitude(), p.getLongitude()) <= radiusKm)
                .map(p -> enrichParkingDTO(parkingMapper.toDTO(p)))
                .collect(Collectors.toList());
    }

    // Calcular distancia entre dos coordenadas usando la fórmula de Haversine
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radio de la Tierra en km
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c; // Distancia en km
    }
    
    // Enriquecer DTO con conteo de espacios dinámico
    private ParkingDTO enrichParkingDTO(ParkingDTO dto) {
        if (dto.getId() == null) {
            dto.setTotalSpaces(0L);
            dto.setOccupiedSpaces(0L);
            return dto;
        }
        
        List<Space> spaces = spaceRepo.findByParkingId(dto.getId());
        long totalSpaces = spaces.size();
        long occupiedSpaces = spaces.stream()
                .filter(s -> "OCCUPIED".equals(s.getStatus()))
                .count();
        
        dto.setTotalSpaces(totalSpaces);
        dto.setOccupiedSpaces(occupiedSpaces);
        
        return dto;
    }
    
}
