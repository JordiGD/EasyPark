package co.edu.uptc.driver.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.entity.Owner;
import co.edu.uptc.driver.mapper.OwnerMapper;
import co.edu.uptc.driver.repo.OwnerRepo;

@ExtendWith(MockitoExtension.class)
class OwnerServiceTest {

    @Mock
    private OwnerRepo ownerRepo;

    @Mock
    private OwnerMapper ownerMapper;

    @InjectMocks
    private OwnerService ownerService;

    private OwnerDTO ownerDTO;
    private Owner owner;

    @BeforeEach
    void setUp() {
        ownerDTO = new OwnerDTO();
        ownerDTO.setOwnerID(1L);
        ownerDTO.setUserID(1L);

        owner = new Owner();
        owner.setOwnerID(1L);
        owner.setUserID(1L);
    }

    @Test
    void testGetOwnerByIdSuccess() {
        // Arrange
        when(ownerRepo.findById(1L)).thenReturn(Optional.of(owner));
        when(ownerMapper.toDTO(owner)).thenReturn(ownerDTO);

        // Act
        OwnerDTO result = ownerService.getOwnerById(1L);

        // Assert
        assertNotNull(result);
        assertEquals(ownerDTO.getOwnerID(), result.getOwnerID());
        assertEquals(ownerDTO.getUserID(), result.getUserID());

        // Verify
        verify(ownerRepo, times(1)).findById(1L);
        verify(ownerMapper, times(1)).toDTO(owner);
    }

    @Test
    void testGetOwnerByIdThrowsExceptionWhenNotFound() {
        // Arrange
        when(ownerRepo.findById(99L)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            ownerService.getOwnerById(99L);
        });

        assertEquals("Owner not found", exception.getMessage());

        // Verify
        verify(ownerRepo, times(1)).findById(99L);
        verify(ownerMapper, never()).toDTO(any());
    }

    @Test
    void testGetOwnerByIdWithDifferentIds() {
        // Arrange
        long testId = 5L;
        Owner testOwner = new Owner();
        testOwner.setOwnerID(testId);
        testOwner.setUserID(10L);

        OwnerDTO testOwnerDTO = new OwnerDTO();
        testOwnerDTO.setOwnerID(testId);
        testOwnerDTO.setUserID(10L);

        when(ownerRepo.findById(testId)).thenReturn(Optional.of(testOwner));
        when(ownerMapper.toDTO(testOwner)).thenReturn(testOwnerDTO);

        // Act
        OwnerDTO result = ownerService.getOwnerById(testId);

        // Assert
        assertNotNull(result);
        assertEquals(testId, result.getOwnerID());
        assertEquals(10L, result.getUserID());

        // Verify
        verify(ownerRepo, times(1)).findById(testId);
    }
}
