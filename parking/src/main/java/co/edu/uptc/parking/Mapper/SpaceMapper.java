package co.edu.uptc.parking.Mapper;

import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import co.edu.uptc.parking.dto.SpaceDTO;
import co.edu.uptc.parking.entity.Space;

@Mapper
public interface SpaceMapper {

    SpaceMapper INSTANCE = Mappers.getMapper(SpaceMapper.class);

    SpaceDTO toDTO(Space space);
    Space toEntity(SpaceDTO spaceDTO);

}
