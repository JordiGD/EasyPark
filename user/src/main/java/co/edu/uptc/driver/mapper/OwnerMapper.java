package co.edu.uptc.driver.mapper;

import org.mapstruct.Mapper;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.entity.Owner;

@Mapper(componentModel = "spring")
public interface OwnerMapper {
    
    OwnerDTO toDTO(Owner owner);
    Owner toEntity(OwnerDTO ownerDTO);
}
