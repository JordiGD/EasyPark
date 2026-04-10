package co.edu.uptc.driver.mapper;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.entity.Owner;

class OwnerMapperTest {

    private Owner owner;
    private OwnerDTO ownerDTO;

    @BeforeEach
    void setUp() {
        owner = new Owner();
        owner.setOwnerID(1L);
        owner.setUserID(1L);

        ownerDTO = new OwnerDTO();
        ownerDTO.setOwnerID(1L);
        ownerDTO.setUserID(1L);
    }

    @Test
    void testOwnerDTOCreation() {
        // Verifica que el DTO se puede crear correctamente
        OwnerDTO dto = new OwnerDTO();
        dto.setOwnerID(1L);
        dto.setUserID(5L);

        assertNotNull(dto);
        assertEquals(1L, dto.getOwnerID());
        assertEquals(5L, dto.getUserID());
    }

    @Test
    void testOwnerEntityCreation() {
        // Verifica que la entidad se puede crear correctamente
        Owner o = new Owner();
        o.setOwnerID(5L);
        o.setUserID(10L);

        assertNotNull(o);
        assertEquals(5L, o.getOwnerID());
        assertEquals(10L, o.getUserID());
    }

    @Test
    void testOwnerFieldMapping() {
        // Verifica que los campos se copian correctamente
        Owner source = new Owner();
        source.setOwnerID(1L);
        source.setUserID(7L);

        OwnerDTO target = new OwnerDTO();
        target.setOwnerID(source.getOwnerID());
        target.setUserID(source.getUserID());

        assertEquals(source.getOwnerID(), target.getOwnerID());
        assertEquals(source.getUserID(), target.getUserID());
    }

    @Test
    void testOwnerDTOWithNullUserID() {
        // Verifica que el DTO puede tener userID nulo
        OwnerDTO dto = new OwnerDTO();
        dto.setOwnerID(3L);
        dto.setUserID(null);

        assertNotNull(dto);
        assertEquals(3L, dto.getOwnerID());
        assertNull(dto.getUserID());
    }

    @Test
    void testOwnerEntityWithNullUserID() {
        // Verifica que la entidad puede tener userID nulo
        Owner o = new Owner();
        o.setOwnerID(7L);
        o.setUserID(null);

        assertNotNull(o);
        assertEquals(7L, o.getOwnerID());
        assertNull(o.getUserID());
    }

    @Test
    void testMultipleOwnersMapping() {
        // Verifica que se pueden crear múltiples propietarios diferentes
        OwnerDTO owner1 = new OwnerDTO(1L, 5L);
        OwnerDTO owner2 = new OwnerDTO(2L, 10L);

        assertNotEquals(owner1.getOwnerID(), owner2.getOwnerID());
        assertNotEquals(owner1.getUserID(), owner2.getUserID());
    }

    @Test
    void testOwnerEqualsAndHashCode() {
        // Verifica que dos owners con los mismos valores son iguales
        Owner o1 = new Owner(1L, 5L);
        Owner o2 = new Owner(1L, 5L);

        assertEquals(o1, o2);
        assertEquals(o1.hashCode(), o2.hashCode());
    }
}
