package co.edu.uptc.driver.service;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.driver.dto.UserDTO;
import co.edu.uptc.driver.entity.User;
import co.edu.uptc.driver.mapper.UserMapper;
import co.edu.uptc.driver.repo.UserRepo;

@Service
public class UserService {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private UserMapper userMapper;

    public UserDTO saveUser(UserDTO userDTO) {
        if (userRepo.existsByEmail(userDTO.getEmail())) {
            throw new RuntimeException("El email ya está registrado");
        }
        User user = userMapper.toEntity(userDTO);
        user.setCreatedAt(LocalDateTime.now());
        User savedUser = userRepo.save(user);
        return userMapper.toDTO(savedUser);
    }

    public UserDTO updateUser(UserDTO userDTO) {
        User existingUser = userRepo.findById(userDTO.getUserID())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        existingUser.setName(userDTO.getName());
        existingUser.setPhoneNumber(userDTO.getPhoneNumber());
        existingUser.setEmail(userDTO.getEmail());
        existingUser.setPassword(userDTO.getPassword());
        existingUser.setRole(userDTO.getRole());

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
    
}
