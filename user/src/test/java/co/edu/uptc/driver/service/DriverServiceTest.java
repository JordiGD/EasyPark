package co.edu.uptc.driver.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.entity.Driver;
import co.edu.uptc.driver.mapper.DriverMapper;
import co.edu.uptc.driver.repo.DriverRepo;

@ExtendWith(MockitoExtension.class)
class DriverServiceTest {

    @Mock
    private DriverRepo driverRepo;

    @Mock
    private DriverMapper driverMapper;

    @InjectMocks
    private DriverService driverService;

    private DriverDTO driverDTO;
    private Driver driver;

    @BeforeEach
    void setUp() {
        // Inicializar datos de prueba
        driverDTO = new DriverDTO();
        driverDTO.setUserID(1L);
        driverDTO.setVehicule("Toyota");
        driverDTO.setPlate("ABC-123");

        driver = new Driver();
        driver.setDriverID(1L);
        driver.setUserID(1L);
        driver.setVehicule("Toyota");
        driver.setPlate("ABC-123");
    }

    @Test
    void testSaveVehicleWhenDriverDoesNotExist() {
        // Arrange
        when(driverRepo.findByUserID(driverDTO.getUserID())).thenReturn(Optional.empty());
        when(driverRepo.save(any(Driver.class))).thenReturn(driver);
        when(driverMapper.toDTO(driver)).thenReturn(driverDTO);

        // Act
        DriverDTO result = driverService.saveVehicule(driverDTO);

        // Assert
        assertNotNull(result);
        assertEquals(driverDTO.getUserID(), result.getUserID());
        assertEquals(driverDTO.getVehicule(), result.getVehicule());
        assertEquals(driverDTO.getPlate(), result.getPlate());

        // Verify
        verify(driverRepo, times(1)).findByUserID(driverDTO.getUserID());
        verify(driverRepo, times(1)).save(any(Driver.class));
        verify(driverMapper, times(1)).toDTO(driver);
    }

    @Test
    void testSaveVehicleWhenDriverExists() {
        // Arrange
        when(driverRepo.findByUserID(driverDTO.getUserID())).thenReturn(Optional.of(driver));
        when(driverRepo.save(any(Driver.class))).thenReturn(driver);
        when(driverMapper.toDTO(driver)).thenReturn(driverDTO);

        // Act
        DriverDTO result = driverService.saveVehicule(driverDTO);

        // Assert
        assertNotNull(result);
        assertEquals(driverDTO.getVehicule(), result.getVehicule());

        // Verify
        verify(driverRepo, times(1)).findByUserID(driverDTO.getUserID());
        verify(driverRepo, times(1)).save(any(Driver.class));
    }

    @Test
    void testUpdateVehicleSuccess() {
        // Arrange
        when(driverRepo.findByUserID(driverDTO.getUserID())).thenReturn(Optional.of(driver));
        when(driverRepo.save(any(Driver.class))).thenReturn(driver);
        when(driverMapper.toDTO(driver)).thenReturn(driverDTO);

        // Act
        DriverDTO result = driverService.updateVehicule(driverDTO);

        // Assert
        assertNotNull(result);
        assertEquals(driverDTO.getVehicule(), result.getVehicule());
        assertEquals(driverDTO.getPlate(), result.getPlate());

        // Verify
        verify(driverRepo, times(1)).findByUserID(driverDTO.getUserID());
        verify(driverRepo, times(1)).save(any(Driver.class));
    }

    @Test
    void testUpdateVehicleThrowsExceptionWhenDriverNotFound() {
        // Arrange
        when(driverRepo.findByUserID(driverDTO.getUserID())).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            driverService.updateVehicule(driverDTO);
        });

        assertEquals("Driver no encontrado para el usuario", exception.getMessage());
        verify(driverRepo, times(1)).findByUserID(driverDTO.getUserID());
        verify(driverRepo, never()).save(any(Driver.class));
    }

    @Test
    void testSaveVehicleUpdatesVehicleAndPlate() {
        // Arrange
        Driver existingDriver = new Driver();
        existingDriver.setDriverID(1L);
        existingDriver.setUserID(1L);
        existingDriver.setVehicule("Honda");
        existingDriver.setPlate("XYZ-789");

        when(driverRepo.findByUserID(driverDTO.getUserID())).thenReturn(Optional.of(existingDriver));
        when(driverRepo.save(any(Driver.class))).thenReturn(driver);
        when(driverMapper.toDTO(driver)).thenReturn(driverDTO);

        // Act
        DriverDTO result = driverService.saveVehicule(driverDTO);

        // Assert
        assertNotNull(result);
        assertEquals("Toyota", result.getVehicule());
        assertEquals("ABC-123", result.getPlate());
    }
}
