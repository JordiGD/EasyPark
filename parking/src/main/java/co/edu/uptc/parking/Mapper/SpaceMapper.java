package co.edu.uptc.parking.Mapper;

import org.mapstruct.Mapper;

import co.edu.uptc.parking.dto.SpaceDTO;
import co.edu.uptc.parking.entity.Space;

@Mapper(componentModel = "spring")
public interface SpaceMapper {

    SpaceDTO toDTO(Space space);
    Space toEntity(SpaceDTO spaceDTO);

}
