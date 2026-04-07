package co.edu.uptc.driver.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.entity.Owner;

@Mapper
public interface OwnerMapper {
    
    OwnerMapper INSTANCE = Mappers.getMapper(OwnerMapper.class);

    OwnerDTO toDTO(Owner owner);
    Owner toEntity(OwnerDTO ownerDTO);
}
