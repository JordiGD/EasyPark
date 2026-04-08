package co.edu.uptc.driver.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.entity.Owner;
import co.edu.uptc.driver.mapper.OwnerMapper;
import co.edu.uptc.driver.repo.OwnerRepo;

@Service
public class OwnerService {

    @Autowired
    private OwnerRepo ownerRepo;

    @Autowired
    private OwnerMapper ownerMapper;

    public OwnerDTO getOwnerById(Long ownerId) {
        Owner owner = ownerRepo.findById(ownerId).orElseThrow(() -> new RuntimeException("Owner not found"));
        return ownerMapper.toDTO(owner);
    }
    
}
