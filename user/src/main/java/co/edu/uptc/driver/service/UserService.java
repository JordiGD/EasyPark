package co.edu.uptc.driver.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.driver.dto.UserDTO;
import co.edu.uptc.driver.entity.User;
import co.edu.uptc.driver.entity.Driver;
import co.edu.uptc.driver.entity.Owner;
import co.edu.uptc.driver.mapper.UserMapper;
import co.edu.uptc.driver.repo.UserRepo;
import co.edu.uptc.driver.repo.OwnerRepo;
import co.edu.uptc.driver.repo.DriverRepo;

@Service
public class UserService {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private OwnerRepo ownerRepo;

    @Autowired
    private DriverRepo driverRepo;

    public UserDTO saveUser(UserDTO userDTO) {
        if (userRepo.existsByEmail(userDTO.getEmail())) {
            throw new RuntimeException("El email ya está registrado");
        }
        User user = userMapper.toEntity(userDTO);
        user.setCreatedAt(LocalDateTime.now());
        User savedUser = userRepo.save(user);

        if ("OWNER".equalsIgnoreCase(userDTO.getRole())) {
            Owner owner = new Owner();
            owner.setUserID(savedUser.getUserID());
            ownerRepo.save(owner);
        } else if ("DRIVER".equalsIgnoreCase(userDTO.getRole())) {
            Driver driver = new Driver();
            driver.setUserID(savedUser.getUserID());
            driverRepo.save(driver);
        } else {
            return userMapper.toDTO(savedUser);
        }

        return userMapper.toDTO(savedUser);
    }

    public UserDTO updateUser(UserDTO userDTO) {
        User existingUser = userRepo.findById(userDTO.getUserID())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        existingUser.setName(userDTO.getName());
        existingUser.setPhoneNumber(userDTO.getPhoneNumber());
        existingUser.setEmail(userDTO.getEmail());
        existingUser.setRole(userDTO.getRole());
        
        // Solo actualizar contraseña si viene con valor
        if (userDTO.getPassword() != null && !userDTO.getPassword().trim().isEmpty()) {
            existingUser.setPassword(userDTO.getPassword());
        }

        User updatedUser = userRepo.save(existingUser);

        return userMapper.toDTO(updatedUser);
    }

    public boolean login(String email, String password) {
        User user = userRepo.findByEmail(email)
                .orElse(null);

        if (user == null) {
            return false;
        }
        return user.getPassword().equals(password);
    }

    public List<UserDTO> getAllUsers() {
        return userRepo.findAll()
                .stream()
                .map(userMapper::toDTO)
                .collect(Collectors.toList());
    }

    public UserDTO getUserByEmail(String email) {
        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return userMapper.toDTO(user);
    }
    
}
