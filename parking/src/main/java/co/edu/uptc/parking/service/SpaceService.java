package co.edu.uptc.parking.service;

import java.util.List;
import java.util.Optional;

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

    public SpaceDTO createSpace(Long parkingId) {
        long spaceCount = spaceRepo.findAll().stream()
                .filter(space -> space.getParkingId().equals(parkingId))
                .count();
        
        Space newSpace = new Space();
        newSpace.setParkingId(parkingId);
        newSpace.setSpaceNumber("SPACE-" + parkingId + "-" + (spaceCount + 1));
        newSpace.setStatus("AVAILABLE");
        
        Space savedSpace = spaceRepo.save(newSpace);
        return SpaceMapper.INSTANCE.toDTO(savedSpace);
    }

    public List<SpaceDTO> getSpacesByParkingId(Long parkingId) {
        List<Space> spaces = spaceRepo.findAll();
        return spaces.stream()
                .filter(space -> space.getParkingId().equals(parkingId))
                .map(SpaceMapper.INSTANCE::toDTO)
                .toList();
    }

    public boolean updateSpaceStatus(Long spaceId, String status) {
        Optional<Space> space = spaceRepo.findById(spaceId);
        
        if (space.isPresent()) {
            Space existingSpace = space.get();
            existingSpace.setStatus(status);
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
