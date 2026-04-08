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

    public OwnerDTO saveParking(OwnerDTO ownerDTO) {
        Owner owner = ownerMapper.toEntity(ownerDTO);
        Owner savedOwner = ownerRepo.save(owner);
        return ownerMapper.toDTO(savedOwner);
    }
    
}
