package co.edu.uptc.driver.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.entity.Driver;

@Mapper(componentModel = "spring")
public interface DriverMapper {
    
    DriverDTO toDTO(Driver driver);
    Driver toEntity(DriverDTO driverDTO);
}
