package co.edu.uptc.parking.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.parking.Mapper.SpaceMapper;
import co.edu.uptc.parking.dto.SpaceDTO;
import co.edu.uptc.parking.entity.Space;
import co.edu.uptc.parking.repo.SpaceRepo;

@Service
public class SpaceService {

    @Autowired
    private SpaceRepo spaceRepo;
    
    @Autowired
    private SpaceMapper spaceMapper;

    public SpaceDTO createSpace(Long parkingId) {
        List<Space> existingSpaces = spaceRepo.findByParkingId(parkingId);
        long spaceCount = existingSpaces.size();
        
        String spaceNumber = "SPACE-" + parkingId + "-" + (spaceCount + 1) + "-" + UUID.randomUUID().toString().substring(0, 8);
        
        Space newSpace = new Space();
        newSpace.setParkingId(parkingId);
        newSpace.setSpaceNumber(spaceNumber);
        newSpace.setStatus("AVAILABLE");
        
        Space savedSpace = spaceRepo.save(newSpace);
        return spaceMapper.toDTO(savedSpace);
    }

    public List<SpaceDTO> getSpaces() {
        List<Space> spaces = spaceRepo.findAll();
        return spaces.stream()
                .map(spaceMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<SpaceDTO> getSpacesByParkingId(Long parkingId) {
        List<Space> spaces = spaceRepo.findByParkingId(parkingId);
        return spaces.stream()
                .map(spaceMapper::toDTO)
                .collect(Collectors.toList());
    }

    public boolean updateSpaceStatus(Long spaceId, String status) {
        Optional<Space> space = spaceRepo.findById(spaceId);
        
        if (space.isPresent()) {
            Space existingSpace = space.get();
            // Limpiar el status de comillas si las tiene
            String cleanStatus = status.replace("\"", "").trim();
            existingSpace.setStatus(cleanStatus);
            spaceRepo.save(existingSpace);
            return true;
        }
        
        return false;
    }

    public String getSpaceStatusById(Long spaceId) {
        Optional<Space> space = spaceRepo.findById(spaceId);
        return space.map(Space::getStatus).orElse("Space not found");
    }
    
}
