package co.edu.uptc.driver.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.entity.Driver;
import co.edu.uptc.driver.mapper.DriverMapper;
import co.edu.uptc.driver.repo.DriverRepo;

@Service
public class DriverService {
  
    @Autowired
    private DriverRepo driverRepo;

    @Autowired
    private DriverMapper driverMapper;

    public DriverDTO saveVehicule(DriverDTO driverDTO) {
        Driver driver = driverRepo.findByUserID(driverDTO.getUserID())
                .orElseGet(() -> {
                    Driver newDriver = new Driver();
                    newDriver.setUserID(driverDTO.getUserID());
                    return newDriver;
                });
        
        driver.setVehicule(driverDTO.getVehicule());
        driver.setPlate(driverDTO.getPlate());
        Driver savedDriver = driverRepo.save(driver);
        return driverMapper.toDTO(savedDriver);
    }

    public DriverDTO updateVehicule(DriverDTO driverDTO) {
        Driver existingDriver = driverRepo.findByUserID(driverDTO.getUserID())
                .orElseThrow(() -> new RuntimeException("Driver no encontrado para el usuario"));

        existingDriver.setVehicule(driverDTO.getVehicule());
        existingDriver.setPlate(driverDTO.getPlate());

        Driver updatedDriver = driverRepo.save(existingDriver);

        return driverMapper.toDTO(updatedDriver);
    }

}
