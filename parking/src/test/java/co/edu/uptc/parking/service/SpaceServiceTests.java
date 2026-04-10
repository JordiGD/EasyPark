package co.edu.uptc.parking.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import co.edu.uptc.parking.Mapper.SpaceMapper;
import co.edu.uptc.parking.dto.SpaceDTO;
import co.edu.uptc.parking.entity.Space;
import co.edu.uptc.parking.repo.SpaceRepo;

@ExtendWith(MockitoExtension.class)
class SpaceServiceTests {

    @Mock
    private SpaceRepo spaceRepo;

    @Mock
    private SpaceMapper spaceMapper;

    @InjectMocks
    private SpaceService spaceService;

    private Space testSpace;
    private SpaceDTO testSpaceDTO;
    private List<Space> existingSpaces;

    @BeforeEach
    void setUp() {
        // Configurar datos de prueba
        testSpace = new Space();
        testSpace.setId(1L);
        testSpace.setParkingId(1L);
        testSpace.setSpaceNumber("SPACE-1-1-abc12345");
        testSpace.setStatus("AVAILABLE");

        testSpaceDTO = new SpaceDTO();
        testSpaceDTO.setId(1L);
        testSpaceDTO.setParkingId(1L);
        testSpaceDTO.setSpaceNumber("SPACE-1-1-abc12345");
        testSpaceDTO.setStatus("AVAILABLE");

        Space existingSpace = new Space();
        existingSpace.setId(2L);
        existingSpace.setParkingId(1L);
        existingSpace.setSpaceNumber("SPACE-1-0-xyz67890");
        existingSpace.setStatus("OCCUPIED");

        existingSpaces = Arrays.asList(existingSpace);
    }

    @Test
    void testCreateSpaceSuccess() {
        // Arrange
        when(spaceRepo.findByParkingId(1L)).thenReturn(existingSpaces);
        when(spaceRepo.save(any(Space.class))).thenReturn(testSpace);
        when(spaceMapper.toDTO(any(Space.class))).thenReturn(testSpaceDTO);

        // Act
        SpaceDTO result = spaceService.createSpace(1L);

        // Assert
        assertNotNull(result);
        assertEquals(testSpaceDTO.getId(), result.getId());
        assertEquals(testSpaceDTO.getParkingId(), result.getParkingId());
        assertEquals("AVAILABLE", result.getStatus());
        verify(spaceRepo, times(1)).findByParkingId(1L);
        verify(spaceRepo, times(1)).save(any(Space.class));
    }

    @Test
    void testCreateSpaceWithNoExistingSpaces() {
        // Arrange
        when(spaceRepo.findByParkingId(2L)).thenReturn(Arrays.asList());
        when(spaceRepo.save(any(Space.class))).thenReturn(testSpace);
        when(spaceMapper.toDTO(any(Space.class))).thenReturn(testSpaceDTO);

        // Act
        SpaceDTO result = spaceService.createSpace(2L);

        // Assert
        assertNotNull(result);
        assertEquals("AVAILABLE", result.getStatus());
        verify(spaceRepo, times(1)).findByParkingId(2L);
        verify(spaceRepo, times(1)).save(any(Space.class));
    }

    @Test
    void testGetSpacesSuccess() {
        // Arrange
        Space space1 = new Space();
        space1.setId(1L);
        space1.setStatus("AVAILABLE");

        Space space2 = new Space();
        space2.setId(2L);
        space2.setStatus("OCCUPIED");

        List<Space> spaces = Arrays.asList(space1, space2);

        SpaceDTO dto1 = new SpaceDTO();
        dto1.setId(1L);
        dto1.setStatus("AVAILABLE");

        SpaceDTO dto2 = new SpaceDTO();
        dto2.setId(2L);
        dto2.setStatus("OCCUPIED");

        when(spaceRepo.findAll()).thenReturn(spaces);
        when(spaceMapper.toDTO(space1)).thenReturn(dto1);
        when(spaceMapper.toDTO(space2)).thenReturn(dto2);

        // Act
        List<SpaceDTO> result = spaceService.getSpaces();

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(spaceRepo, times(1)).findAll();
    }

    @Test
    void testGetSpacesEmpty() {
        // Arrange
        when(spaceRepo.findAll()).thenReturn(Arrays.asList());

        // Act
        List<SpaceDTO> result = spaceService.getSpaces();

        // Assert
        assertNotNull(result);
        assertEquals(0, result.size());
        verify(spaceRepo, times(1)).findAll();
    }

    @Test
    void testGetSpacesByParkingIdSuccess() {
        // Arrange
        Space space1 = new Space();
        space1.setId(1L);
        space1.setParkingId(1L);
        space1.setStatus("AVAILABLE");

        Space space2 = new Space();
        space2.setId(2L);
        space2.setParkingId(1L);
        space2.setStatus("OCCUPIED");

        List<Space> spaces = Arrays.asList(space1, space2);

        SpaceDTO dto1 = new SpaceDTO();
        dto1.setId(1L);
        dto1.setParkingId(1L);
        dto1.setStatus("AVAILABLE");

        SpaceDTO dto2 = new SpaceDTO();
        dto2.setId(2L);
        dto2.setParkingId(1L);
        dto2.setStatus("OCCUPIED");

        when(spaceRepo.findByParkingId(1L)).thenReturn(spaces);
        when(spaceMapper.toDTO(space1)).thenReturn(dto1);
        when(spaceMapper.toDTO(space2)).thenReturn(dto2);

        // Act
        List<SpaceDTO> result = spaceService.getSpacesByParkingId(1L);

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(spaceRepo, times(1)).findByParkingId(1L);
    }

    @Test
    void testGetSpacesByParkingIdEmpty() {
        // Arrange
        when(spaceRepo.findByParkingId(999L)).thenReturn(Arrays.asList());

        // Act
        List<SpaceDTO> result = spaceService.getSpacesByParkingId(999L);

        // Assert
        assertNotNull(result);
        assertEquals(0, result.size());
        verify(spaceRepo, times(1)).findByParkingId(999L);
    }

    @Test
    void testUpdateSpaceStatusSuccess() {
        // Arrange
        when(spaceRepo.findById(1L)).thenReturn(Optional.of(testSpace));
        when(spaceRepo.save(any(Space.class))).thenReturn(testSpace);

        // Act
        boolean result = spaceService.updateSpaceStatus(1L, "OCCUPIED");

        // Assert
        assertTrue(result);
        verify(spaceRepo, times(1)).findById(1L);
        verify(spaceRepo, times(1)).save(any(Space.class));
    }

    @Test
    void testUpdateSpaceStatusNotFound() {
        // Arrange
        when(spaceRepo.findById(999L)).thenReturn(Optional.empty());

        // Act
        boolean result = spaceService.updateSpaceStatus(999L, "OCCUPIED");

        // Assert
        assertFalse(result);
        verify(spaceRepo, times(1)).findById(999L);
        verify(spaceRepo, never()).save(any(Space.class));
    }

    @Test
    void testUpdateSpaceStatusToDifferentStatuses() {
        // Arrange
        when(spaceRepo.findById(1L)).thenReturn(Optional.of(testSpace));
        when(spaceRepo.save(any(Space.class))).thenReturn(testSpace);

        // Act & Assert - Test multiple status transitions
        assertTrue(spaceService.updateSpaceStatus(1L, "OCCUPIED"));
        assertTrue(spaceService.updateSpaceStatus(1L, "AVAILABLE"));
        assertTrue(spaceService.updateSpaceStatus(1L, "MAINTENANCE"));

        verify(spaceRepo, times(3)).findById(1L);
        verify(spaceRepo, times(3)).save(any(Space.class));
    }

    @Test
    void testGetSpaceStatusByIdSuccess() {
        // Arrange
        when(spaceRepo.findById(1L)).thenReturn(Optional.of(testSpace));

        // Act
        String result = spaceService.getSpaceStatusById(1L);

        // Assert
        assertNotNull(result);
        assertEquals("AVAILABLE", result);
        verify(spaceRepo, times(1)).findById(1L);
    }

    @Test
    void testGetSpaceStatusByIdNotFound() {
        // Arrange
        when(spaceRepo.findById(999L)).thenReturn(Optional.empty());

        // Act
        String result = spaceService.getSpaceStatusById(999L);

        // Assert
        assertNotNull(result);
        assertEquals("Space not found", result);
        verify(spaceRepo, times(1)).findById(999L);
    }

    @Test
    void testGetSpaceStatusByIdOccupied() {
        // Arrange
        testSpace.setStatus("OCCUPIED");
        when(spaceRepo.findById(1L)).thenReturn(Optional.of(testSpace));

        // Act
        String result = spaceService.getSpaceStatusById(1L);

        // Assert
        assertEquals("OCCUPIED", result);
        verify(spaceRepo, times(1)).findById(1L);
    }
}
