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

import co.edu.uptc.parking.Mapper.ParkingMapper;
import co.edu.uptc.parking.dto.ParkingDTO;
import co.edu.uptc.parking.entity.Parking;
import co.edu.uptc.parking.entity.Space;
import co.edu.uptc.parking.repo.ParkingRepo;
import co.edu.uptc.parking.repo.SpaceRepo;

@ExtendWith(MockitoExtension.class)
class ParkingServiceTests {

    @Mock
    private ParkingRepo parkingRepo;

    @Mock
    private SpaceRepo spaceRepo;

    @Mock
    private ParkingMapper parkingMapper;

    @InjectMocks
    private ParkingService parkingService;

    private Parking testParking;
    private ParkingDTO testParkingDTO;
    private List<Space> testSpaces;

    @BeforeEach
    void setUp() {
        // Configurar datos de prueba
        testParking = new Parking();
        testParking.setId(1L);
        testParking.setOwnerId(100L);
        testParking.setName("Parking Central");
        testParking.setAddress("Calle Principal 123");
        testParking.setPricePerHour(5.0);
        testParking.setAvailability(true);
        testParking.setLatitude(4.7110);
        testParking.setLongitude(-74.0721);

        testParkingDTO = new ParkingDTO();
        testParkingDTO.setId(1L);
        testParkingDTO.setOwnerId(100L);
        testParkingDTO.setName("Parking Central");
        testParkingDTO.setAddress("Calle Principal 123");
        testParkingDTO.setPricePerHour(5.0);
        testParkingDTO.setAvailability(true);
        testParkingDTO.setLatitude(4.7110);
        testParkingDTO.setLongitude(-74.0721);

        Space space1 = new Space();
        space1.setId(1L);
        space1.setParkingId(1L);
        space1.setStatus("AVAILABLE");

        Space space2 = new Space();
        space2.setId(2L);
        space2.setParkingId(1L);
        space2.setStatus("OCCUPIED");

        testSpaces = Arrays.asList(space1, space2);
    }

    @Test
    void testSaveParkingSuccess() {
        // Arrange
        when(parkingMapper.toEntity(any(ParkingDTO.class))).thenReturn(testParking);
        when(parkingRepo.save(any(Parking.class))).thenReturn(testParking);
        when(parkingMapper.toDTO(any(Parking.class))).thenReturn(testParkingDTO);
        when(spaceRepo.findByParkingId(anyLong())).thenReturn(testSpaces);

        // Act
        ParkingDTO result = parkingService.saveParking(testParkingDTO);

        // Assert
        assertNotNull(result);
        assertEquals(testParkingDTO.getId(), result.getId());
        assertEquals(testParkingDTO.getName(), result.getName());
        verify(parkingRepo, times(1)).save(any(Parking.class));
        verify(parkingMapper, times(1)).toEntity(any(ParkingDTO.class));
    }

    @Test
    void testGetParkingByIdSuccess() {
        // Arrange
        when(parkingRepo.findById(1L)).thenReturn(Optional.of(testParking));
        when(parkingMapper.toDTO(any(Parking.class))).thenReturn(testParkingDTO);
        when(spaceRepo.findByParkingId(1L)).thenReturn(testSpaces);

        // Act
        ParkingDTO result = parkingService.getParkingById(1L);

        // Assert
        assertNotNull(result);
        assertEquals(testParkingDTO.getId(), result.getId());
        assertEquals(testParkingDTO.getName(), result.getName());
        verify(parkingRepo, times(1)).findById(1L);
    }

    @Test
    void testGetParkingByIdNotFound() {
        // Arrange
        when(parkingRepo.findById(999L)).thenReturn(Optional.empty());

        // Act
        ParkingDTO result = parkingService.getParkingById(999L);

        // Assert
        assertNull(result);
        verify(parkingRepo, times(1)).findById(999L);
    }

    @Test
    void testGetStatusParkingByIdTrue() {
        // Arrange
        when(parkingRepo.findById(1L)).thenReturn(Optional.of(testParking));

        // Act
        boolean result = parkingService.getStatusParkingById(1L);

        // Assert
        assertTrue(result);
        verify(parkingRepo, times(1)).findById(1L);
    }

    @Test
    void testGetStatusParkingByIdFalse() {
        // Arrange
        testParking.setAvailability(false);
        when(parkingRepo.findById(1L)).thenReturn(Optional.of(testParking));

        // Act
        boolean result = parkingService.getStatusParkingById(1L);

        // Assert
        assertFalse(result);
        verify(parkingRepo, times(1)).findById(1L);
    }

    @Test
    void testGetStatusParkingByIdNotFound() {
        // Arrange
        when(parkingRepo.findById(999L)).thenReturn(Optional.empty());

        // Act
        boolean result = parkingService.getStatusParkingById(999L);

        // Assert
        assertFalse(result);
        verify(parkingRepo, times(1)).findById(999L);
    }

    @Test
    void testUpdateParkingSuccess() {
        // Arrange
        ParkingDTO updateDTO = new ParkingDTO();
        updateDTO.setName("Parking Actualizado");
        updateDTO.setAddress("Nueva Dirección");
        updateDTO.setPricePerHour(7.0);

        when(parkingRepo.findById(1L)).thenReturn(Optional.of(testParking));
        when(parkingRepo.save(any(Parking.class))).thenReturn(testParking);
        when(parkingMapper.toDTO(any(Parking.class))).thenReturn(testParkingDTO);
        when(spaceRepo.findByParkingId(1L)).thenReturn(testSpaces);

        // Act
        ParkingDTO result = parkingService.updateParking(1L, updateDTO);

        // Assert
        assertNotNull(result);
        verify(parkingRepo, times(1)).findById(1L);
        verify(parkingRepo, times(1)).save(any(Parking.class));
    }

    @Test
    void testUpdateParkingNotFound() {
        // Arrange
        when(parkingRepo.findById(999L)).thenReturn(Optional.empty());

        // Act
        ParkingDTO result = parkingService.updateParking(999L, testParkingDTO);

        // Assert
        assertNull(result);
        verify(parkingRepo, times(1)).findById(999L);
        verify(parkingRepo, never()).save(any(Parking.class));
    }

    @Test
    void testGetParkingByOwnerIdSuccess() {
        // Arrange
        Parking parking1 = new Parking();
        parking1.setId(1L);
        parking1.setOwnerId(100L);
        parking1.setName("Parking 1");

        Parking parking2 = new Parking();
        parking2.setId(2L);
        parking2.setOwnerId(100L);
        parking2.setName("Parking 2");

        List<Parking> parkings = Arrays.asList(parking1, parking2);

        ParkingDTO dto1 = new ParkingDTO();
        dto1.setId(1L);
        dto1.setOwnerId(100L);
        dto1.setName("Parking 1");

        ParkingDTO dto2 = new ParkingDTO();
        dto2.setId(2L);
        dto2.setOwnerId(100L);
        dto2.setName("Parking 2");

        when(parkingRepo.findAll()).thenReturn(parkings);
        when(parkingMapper.toDTO(parking1)).thenReturn(dto1);
        when(parkingMapper.toDTO(parking2)).thenReturn(dto2);
        when(spaceRepo.findByParkingId(anyLong())).thenReturn(testSpaces);

        // Act
        List<ParkingDTO> result = parkingService.getParkingByOwnerId(100L);

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(parkingRepo, times(1)).findAll();
    }

    @Test
    void testGetParkingByOwnerIdEmpty() {
        // Arrange
        when(parkingRepo.findAll()).thenReturn(Arrays.asList());

        // Act
        List<ParkingDTO> result = parkingService.getParkingByOwnerId(999L);

        // Assert
        assertNotNull(result);
        assertEquals(0, result.size());
        verify(parkingRepo, times(1)).findAll();
    }

    @Test
    void testGetAllParkingsSuccess() {
        // Arrange
        Parking parking1 = new Parking();
        parking1.setId(1L);
        parking1.setName("Parking 1");

        Parking parking2 = new Parking();
        parking2.setId(2L);
        parking2.setName("Parking 2");

        List<Parking> parkings = Arrays.asList(parking1, parking2);

        ParkingDTO dto1 = new ParkingDTO();
        dto1.setId(1L);
        dto1.setName("Parking 1");

        ParkingDTO dto2 = new ParkingDTO();
        dto2.setId(2L);
        dto2.setName("Parking 2");

        when(parkingRepo.findAll()).thenReturn(parkings);
        when(parkingMapper.toDTO(parking1)).thenReturn(dto1);
        when(parkingMapper.toDTO(parking2)).thenReturn(dto2);
        when(spaceRepo.findByParkingId(anyLong())).thenReturn(testSpaces);

        // Act
        List<ParkingDTO> result = parkingService.getAllParkings();

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(parkingRepo, times(1)).findAll();
    }

    @Test
    void testGetAllParkingsEmpty() {
        // Arrange
        when(parkingRepo.findAll()).thenReturn(Arrays.asList());

        // Act
        List<ParkingDTO> result = parkingService.getAllParkings();

        // Assert
        assertNotNull(result);
        assertEquals(0, result.size());
        verify(parkingRepo, times(1)).findAll();
    }
}
