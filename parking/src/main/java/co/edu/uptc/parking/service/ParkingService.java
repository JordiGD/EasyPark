package co.edu.uptc.parking.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.parking.Mapper.ParkingMapper;
import co.edu.uptc.parking.dto.ParkingDTO;
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

    public ParkingDTO saveParking(ParkingDTO parkingDTO) {
        Parking parking = parkingMapper.toEntity(parkingDTO);
        Parking savedParking = parkingRepo.save(parking);
        return enrichParkingDTO(parkingMapper.toDTO(savedParking));
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
            parking.setLatitude(parkingDTO.getLatitude());
            parking.setLongitude(parkingDTO.getLongitude());
            
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
