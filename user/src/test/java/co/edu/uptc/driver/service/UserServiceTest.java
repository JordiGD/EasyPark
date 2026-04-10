package co.edu.uptc.driver.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import co.edu.uptc.driver.dto.UserDTO;
import co.edu.uptc.driver.entity.Driver;
import co.edu.uptc.driver.entity.Owner;
import co.edu.uptc.driver.entity.User;
import co.edu.uptc.driver.mapper.UserMapper;
import co.edu.uptc.driver.repo.DriverRepo;
import co.edu.uptc.driver.repo.OwnerRepo;
import co.edu.uptc.driver.repo.UserRepo;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepo userRepo;

    @Mock
    private UserMapper userMapper;

    @Mock
    private OwnerRepo ownerRepo;

    @Mock
    private DriverRepo driverRepo;

    @InjectMocks
    private UserService userService;

    private UserDTO userDTO;
    private User user;
    private LocalDateTime createdAt;

    @BeforeEach
    void setUp() {
        createdAt = LocalDateTime.now();
        
        userDTO = new UserDTO();
        userDTO.setUserID(1L);
        userDTO.setName("Juan Pérez");
        userDTO.setEmail("juan@example.com");
        userDTO.setPhoneNumber("3001234567");
        userDTO.setPassword("password123");
        userDTO.setRole("DRIVER");

        user = new User();
        user.setUserID(1L);
        user.setName("Juan Pérez");
        user.setEmail("juan@example.com");
        user.setPhoneNumber("3001234567");
        user.setPassword("password123");
        user.setRole("DRIVER");
        user.setCreatedAt(createdAt);
    }

    @Test
    void testSaveUserWithDriverRole() {
        // Arrange
        when(userRepo.existsByEmail(userDTO.getEmail())).thenReturn(false);
        when(userMapper.toEntity(userDTO)).thenReturn(user);
        when(userRepo.save(any(User.class))).thenReturn(user);
        when(driverRepo.save(any(Driver.class))).thenReturn(new Driver());
        when(userMapper.toDTO(user)).thenReturn(userDTO);

        // Act
        UserDTO result = userService.saveUser(userDTO);

        // Assert
        assertNotNull(result);
        assertEquals(userDTO.getEmail(), result.getEmail());
        assertEquals("DRIVER", result.getRole());

        // Verify
        verify(userRepo, times(1)).existsByEmail(userDTO.getEmail());
        verify(userRepo, times(1)).save(any(User.class));
        verify(driverRepo, times(1)).save(any(Driver.class));
    }

    @Test
    void testSaveUserWithOwnerRole() {
        // Arrange
        userDTO.setRole("OWNER");
        user.setRole("OWNER");
        
        when(userRepo.existsByEmail(userDTO.getEmail())).thenReturn(false);
        when(userMapper.toEntity(userDTO)).thenReturn(user);
        when(userRepo.save(any(User.class))).thenReturn(user);
        when(ownerRepo.save(any(Owner.class))).thenReturn(new Owner());
        when(userMapper.toDTO(user)).thenReturn(userDTO);

        // Act
        UserDTO result = userService.saveUser(userDTO);

        // Assert
        assertNotNull(result);
        assertEquals("OWNER", result.getRole());

        // Verify
        verify(userRepo, times(1)).existsByEmail(userDTO.getEmail());
        verify(ownerRepo, times(1)).save(any(Owner.class));
    }

    @Test
    void testSaveUserThrowsExceptionWhenEmailAlreadyExists() {
        // Arrange
        when(userRepo.existsByEmail(userDTO.getEmail())).thenReturn(true);

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.saveUser(userDTO);
        });

        assertEquals("El email ya está registrado", exception.getMessage());
        verify(userRepo, times(1)).existsByEmail(userDTO.getEmail());
        verify(userRepo, never()).save(any(User.class));
    }

    @Test
    void testUpdateUserSuccess() {
        // Arrange
        when(userRepo.findById(userDTO.getUserID())).thenReturn(Optional.of(user));
        when(userRepo.save(any(User.class))).thenReturn(user);
        when(userMapper.toDTO(user)).thenReturn(userDTO);

        // Act
        UserDTO result = userService.updateUser(userDTO);

        // Assert
        assertNotNull(result);
        assertEquals(userDTO.getName(), result.getName());

        // Verify
        verify(userRepo, times(1)).findById(userDTO.getUserID());
        verify(userRepo, times(1)).save(any(User.class));
    }

    @Test
    void testUpdateUserThrowsExceptionWhenUserNotFound() {
        // Arrange
        when(userRepo.findById(userDTO.getUserID())).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.updateUser(userDTO);
        });

        assertEquals("Usuario no encontrado", exception.getMessage());
        verify(userRepo, never()).save(any(User.class));
    }

    @Test
    void testUpdateUserWithoutPassword() {
        // Arrange
        userDTO.setPassword(null);
        String originalPassword = "original123";
        user.setPassword(originalPassword);

        when(userRepo.findById(userDTO.getUserID())).thenReturn(Optional.of(user));
        when(userRepo.save(any(User.class))).thenReturn(user);
        when(userMapper.toDTO(user)).thenReturn(userDTO);

        // Act
        userService.updateUser(userDTO);

        // Assert
        verify(userRepo, times(1)).findById(userDTO.getUserID());
        verify(userRepo, times(1)).save(any(User.class));
    }

    @Test
    void testLoginSuccess() {
        // Arrange
        when(userRepo.findByEmail(userDTO.getEmail())).thenReturn(Optional.of(user));

        // Act
        boolean result = userService.login(userDTO.getEmail(), "password123");

        // Assert
        assertTrue(result);
        verify(userRepo, times(1)).findByEmail(userDTO.getEmail());
    }

    @Test
    void testLoginFailsWithWrongPassword() {
        // Arrange
        when(userRepo.findByEmail(userDTO.getEmail())).thenReturn(Optional.of(user));

        // Act
        boolean result = userService.login(userDTO.getEmail(), "wrongpassword");

        // Assert
        assertFalse(result);
    }

    @Test
    void testLoginFailsWhenUserNotFound() {
        // Arrange
        when(userRepo.findByEmail(userDTO.getEmail())).thenReturn(Optional.empty());

        // Act
        boolean result = userService.login(userDTO.getEmail(), "password123");

        // Assert
        assertFalse(result);
        verify(userRepo, times(1)).findByEmail(userDTO.getEmail());
    }

    @Test
    void testGetAllUsers() {
        // Arrange
        User user2 = new User();
        user2.setUserID(2L);
        user2.setName("María García");
        user2.setEmail("maria@example.com");

        UserDTO userDTO2 = new UserDTO();
        userDTO2.setUserID(2L);
        userDTO2.setName("María García");
        userDTO2.setEmail("maria@example.com");

        List<User> users = Arrays.asList(user, user2);

        when(userRepo.findAll()).thenReturn(users);
        when(userMapper.toDTO(user)).thenReturn(userDTO);
        when(userMapper.toDTO(user2)).thenReturn(userDTO2);

        // Act
        List<UserDTO> result = userService.getAllUsers();

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(userRepo, times(1)).findAll();
    }

    @Test
    void testGetUserByEmailSuccess() {
        // Arrange
        when(userRepo.findByEmail(userDTO.getEmail())).thenReturn(Optional.of(user));
        when(userMapper.toDTO(user)).thenReturn(userDTO);

        // Act
        UserDTO result = userService.getUserByEmail(userDTO.getEmail());

        // Assert
        assertNotNull(result);
        assertEquals(userDTO.getEmail(), result.getEmail());
        verify(userRepo, times(1)).findByEmail(userDTO.getEmail());
    }

    @Test
    void testGetUserByEmailThrowsExceptionWhenNotFound() {
        // Arrange
        when(userRepo.findByEmail(userDTO.getEmail())).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.getUserByEmail(userDTO.getEmail());
        });

        assertEquals("Usuario no encontrado", exception.getMessage());
    }

    @Test
    void testSaveUserWithUnknownRole() {
        // Arrange
        userDTO.setRole("UNKNOWN");
        user.setRole("UNKNOWN");
        
        when(userRepo.existsByEmail(userDTO.getEmail())).thenReturn(false);
        when(userMapper.toEntity(userDTO)).thenReturn(user);
        when(userRepo.save(any(User.class))).thenReturn(user);
        when(userMapper.toDTO(user)).thenReturn(userDTO);

        // Act
        UserDTO result = userService.saveUser(userDTO);

        // Assert
        assertNotNull(result);
        verify(ownerRepo, never()).save(any(Owner.class));
        verify(driverRepo, never()).save(any(Driver.class));
    }
}
