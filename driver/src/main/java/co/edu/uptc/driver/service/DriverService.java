package co.edu.uptc.driver.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.entity.Driver;
import co.edu.uptc.driver.mapper.DriverMapper;
import co.edu.uptc.driver.repo.DriverRepo;

@Service
public class DriverService {
  
    private DriverRepo driverRepo;

    public DriverDTO createDriver(DriverDTO driverDTO) {
        Driver driver = driverRepo.save(DriverMapper.INSTANCE.toEntity(driverDTO));
        return DriverMapper.INSTANCE.toDTO(driver);
    }

    public List<DriverDTO> getAllDrivers() {
        List<Driver> drivers = driverRepo.findAll();
        return drivers.stream().map(DriverMapper.INSTANCE::toDTO).collect(Collectors.toList());
    }
}
