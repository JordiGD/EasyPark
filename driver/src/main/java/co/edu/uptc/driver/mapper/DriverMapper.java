package co.edu.uptc.driver.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.entity.Driver;

@Mapper
public interface DriverMapper {
    
    DriverMapper INSTANCE = Mappers.getMapper(DriverMapper.class);

    DriverDTO toDTO(Driver driver);
    Driver toEntity(DriverDTO driverDTO);
}
