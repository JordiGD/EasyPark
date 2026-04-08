package co.edu.uptc.parking.Mapper;

import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import co.edu.uptc.parking.dto.ParkingDTO;
import co.edu.uptc.parking.entity.Parking;

@Mapper
public interface ParkingMapper {

    ParkingMapper INSTANCE = Mappers.getMapper(ParkingMapper.class);

    ParkingDTO toDTO(Parking parking);
    Parking toEntity(ParkingDTO parkingDTO);

}
