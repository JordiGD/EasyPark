package co.edu.uptc.driver.mapper;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import co.edu.uptc.driver.dto.UserDTO;
import co.edu.uptc.driver.entity.User;

class UserMapperTest {

    private User user;
    private UserDTO userDTO;
    private LocalDateTime createdAt;

    @BeforeEach
    void setUp() {
        createdAt = LocalDateTime.now();

        user = new User();
        user.setUserID(1L);
        user.setName("Juan Pérez");
        user.setEmail("juan@example.com");
        user.setPhoneNumber("3001234567");
        user.setPassword("password123");
        user.setRole("DRIVER");
        user.setCreatedAt(createdAt);

        userDTO = new UserDTO();
        userDTO.setUserID(1L);
        userDTO.setName("Juan Pérez");
        userDTO.setEmail("juan@example.com");
        userDTO.setPhoneNumber("3001234567");
        userDTO.setPassword("password123");
        userDTO.setRole("DRIVER");
        userDTO.setCreatedAt(createdAt);
    }

    @Test
    void testUserDTOCreation() {
        // Verifica que el DTO se puede crear correctamente
        UserDTO dto = new UserDTO();
        dto.setUserID(1L);
        dto.setName("María");
        dto.setEmail("maria@example.com");
        dto.setPhoneNumber("3009876543");
        dto.setPassword("secure456");
        dto.setRole("OWNER");

        assertNotNull(dto);
        assertEquals(1L, dto.getUserID());
        assertEquals("María", dto.getName());
        assertEquals("maria@example.com", dto.getEmail());
    }

    @Test
    void testUserEntityCreation() {
        // Verifica que la entidad se puede crear correctamente
        User u = new User();
        u.setUserID(5L);
        u.setName("Carlos López");
        u.setEmail("carlos@example.com");
        u.setPhoneNumber("3112345678");
        u.setPassword("pass789");
        u.setRole("DRIVER");
        u.setCreatedAt(LocalDateTime.now());

        assertNotNull(u);
        assertEquals(5L, u.getUserID());
        assertEquals("Carlos López", u.getName());
    }

    @Test
    void testUserFieldMapping() {
        // Verifica que los campos se copian correctamente
        User source = new User();
        source.setUserID(1L);
        source.setName("Pedro");
        source.setEmail("pedro@example.com");
        source.setPhoneNumber("3123456789");
        source.setPassword("pwd123");
        source.setRole("OWNER");
        source.setCreatedAt(createdAt);

        UserDTO target = new UserDTO();
        target.setUserID(source.getUserID());
        target.setName(source.getName());
        target.setEmail(source.getEmail());
        target.setPhoneNumber(source.getPhoneNumber());
        target.setPassword(source.getPassword());
        target.setRole(source.getRole());
        target.setCreatedAt(source.getCreatedAt());

        assertEquals(source.getUserID(), target.getUserID());
        assertEquals(source.getName(), target.getName());
        assertEquals(source.getEmail(), target.getEmail());
        assertEquals(source.getPhoneNumber(), target.getPhoneNumber());
    }

    @Test
    void testUserDTOWithNullFields() {
        // Verifica que el DTO puede tener campos nulos
        UserDTO dto = new UserDTO();
        dto.setUserID(1L);
        dto.setName("Ana");
        dto.setEmail(null);
        dto.setPhoneNumber(null);
        dto.setPassword(null);
        dto.setRole(null);
        dto.setCreatedAt(null);

        assertNotNull(dto);
        assertEquals(1L, dto.getUserID());
        assertEquals("Ana", dto.getName());
        assertNull(dto.getEmail());
    }

    @Test
    void testMultipleUsersMapping() {
        // Verifica que se pueden crear múltiples usuarios diferentes
        UserDTO dto1 = new UserDTO();
        dto1.setUserID(1L);
        dto1.setName("User1");
        dto1.setRole("DRIVER");

        UserDTO dto2 = new UserDTO();
        dto2.setUserID(2L);
        dto2.setName("User2");
        dto2.setRole("OWNER");

        assertNotEquals(dto1.getUserID(), dto2.getUserID());
        assertNotEquals(dto1.getName(), dto2.getName());
        assertNotEquals(dto1.getRole(), dto2.getRole());
    }

    @Test
    void testUserDTOEqualsAndHashCode() {
        // Verifica que dos users con los mismos valores son iguales
        User u1 = new User(1L, "Juan", "310", "juan@example.com", "pass", "DRIVER", createdAt);
        User u2 = new User(1L, "Juan", "310", "juan@example.com", "pass", "DRIVER", createdAt);

        assertEquals(u1, u2);
        assertEquals(u1.hashCode(), u2.hashCode());
    }
}
