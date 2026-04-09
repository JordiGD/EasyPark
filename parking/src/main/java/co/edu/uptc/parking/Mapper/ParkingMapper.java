package co.edu.uptc.parking.Mapper;

import org.mapstruct.Mapper;

import co.edu.uptc.parking.dto.ParkingDTO;
import co.edu.uptc.parking.entity.Parking;

@Mapper(componentModel = "spring")
public interface ParkingMapper {

    ParkingDTO toDTO(Parking parking);
    Parking toEntity(ParkingDTO parkingDTO);

}
