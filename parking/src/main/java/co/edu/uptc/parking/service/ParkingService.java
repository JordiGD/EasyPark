package co.edu.uptc.parking.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.parking.Mapper.ParkingMapper;
import co.edu.uptc.parking.dto.ParkingDTO;
import co.edu.uptc.parking.entity.Parking;
import co.edu.uptc.parking.repo.ParkingRepo;

@Service
public class ParkingService {

    @Autowired
    private ParkingRepo parkingRepo;

    public ParkingDTO saveParking(ParkingDTO parkingDTO) {
        Parking parking = ParkingMapper.INSTANCE.toEntity(parkingDTO);
        Parking savedParking = parkingRepo.save(parking);
        return ParkingMapper.INSTANCE.toDTO(savedParking);
    }

    public ParkingDTO getParkingById(Long id) {
        Optional<Parking> parking = parkingRepo.findById(id);
        return parking.map(ParkingMapper.INSTANCE::toDTO).orElse(null);
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
            return ParkingMapper.INSTANCE.toDTO(updatedParking);
        }
        
        return null;
    }

    public List<ParkingDTO> getParkingByOwnerId(Long ownerId) {
        List<Parking> parkings = parkingRepo.findAll();
        return parkings.stream()
                .filter(parking -> parking.getOwnerId().equals(ownerId))
                .map(ParkingMapper.INSTANCE::toDTO)
                .collect(Collectors.toList());
    }

    public List<ParkingDTO> getAllParkings() {
        List<Parking> parkings = parkingRepo.findAll();
        return parkings.stream()
                .map(ParkingMapper.INSTANCE::toDTO)
                .collect(Collectors.toList());
    }
    
}
