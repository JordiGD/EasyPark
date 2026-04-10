package co.edu.uptc.driver.mapper;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.entity.Driver;

class DriverMapperTest {

    private Driver driver;
    private DriverDTO driverDTO;

    @BeforeEach
    void setUp() {
        driver = new Driver();
        driver.setDriverID(1L);
        driver.setUserID(1L);
        driver.setVehicule("Toyota Corolla");
        driver.setPlate("ABC-1234");

        driverDTO = new DriverDTO();
        driverDTO.setDriverID(1L);
        driverDTO.setUserID(1L);
        driverDTO.setVehicule("Toyota Corolla");
        driverDTO.setPlate("ABC-1234");
    }

    @Test
    void testDriverDTOCreation() {
        // Verifica que el DTO se puede crear correctamente
        DriverDTO dto = new DriverDTO();
        dto.setDriverID(1L);
        dto.setUserID(1L);
        dto.setVehicule("Honda");
        dto.setPlate("XYZ-999");

        assertNotNull(dto);
        assertEquals(1L, dto.getDriverID());
        assertEquals(1L, dto.getUserID());
        assertEquals("Honda", dto.getVehicule());
        assertEquals("XYZ-999", dto.getPlate());
    }

    @Test
    void testDriverEntityCreation() {
        // Verifica que la entidad se puede crear correctamente
        Driver d = new Driver();
        d.setDriverID(5L);
        d.setUserID(10L);
        d.setVehicule("Toyota");
        d.setPlate("ABC-123");

        assertNotNull(d);
        assertEquals(5L, d.getDriverID());
        assertEquals(10L, d.getUserID());
        assertEquals("Toyota", d.getVehicule());
        assertEquals("ABC-123", d.getPlate());
    }

    @Test
    void testDriverFieldMapping() {
        // Verifica que los campos se copian correctamente
        Driver source = new Driver();
        source.setDriverID(1L);
        source.setUserID(5L);
        source.setVehicule("Honda");
        source.setPlate("HIJ-456");

        DriverDTO target = new DriverDTO();
        target.setDriverID(source.getDriverID());
        target.setUserID(source.getUserID());
        target.setVehicule(source.getVehicule());
        target.setPlate(source.getPlate());

        assertEquals(source.getDriverID(), target.getDriverID());
        assertEquals(source.getUserID(), target.getUserID());
        assertEquals(source.getVehicule(), target.getVehicule());
        assertEquals(source.getPlate(), target.getPlate());
    }

    @Test
    void testDriverDTOWithNullFields() {
        // Verifica que el DTO puede tener campos nulos
        DriverDTO dto = new DriverDTO();
        dto.setDriverID(1L);
        dto.setUserID(null);
        dto.setVehicule(null);
        dto.setPlate(null);

        assertNotNull(dto);
        assertEquals(1L, dto.getDriverID());
        assertNull(dto.getUserID());
        assertNull(dto.getVehicule());
        assertNull(dto.getPlate());
    }

    @Test
    void testDriverEntityEqualsAndHashCode() {
        //Verifica que dos drivers con los mismos valores son iguales
        Driver d1 = new Driver(1L, 5L, "Toyota", "ABC-123");
        Driver d2 = new Driver(1L, 5L, "Toyota", "ABC-123");

        assertEquals(d1, d2);
        assertEquals(d1.hashCode(), d2.hashCode());
    }
}
