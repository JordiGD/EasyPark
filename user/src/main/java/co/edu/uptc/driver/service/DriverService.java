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
        Driver driver = driverMapper.toEntity(driverDTO);
        Driver savedDriver = driverRepo.save(driver);
        return driverMapper.toDTO(savedDriver);
    }

    public DriverDTO updateVehicule(DriverDTO driverDTO) {
        Driver existingDriver = driverRepo.findById(driverDTO.getDriverID())
                .orElseThrow(() -> new RuntimeException("Vehículo no encontrado"));

        existingDriver.setUserID(driverDTO.getUserID());
        existingDriver.setVehicule(driverDTO.getVehicule());
        existingDriver.setPlate(driverDTO.getPlate());

        Driver updatedDriver = driverRepo.save(existingDriver);

        return driverMapper.toDTO(updatedDriver);
    }

}
