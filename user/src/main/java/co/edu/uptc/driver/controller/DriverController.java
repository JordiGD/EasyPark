package co.edu.uptc.driver.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import co.edu.uptc.driver.dto.DriverDTO;
import co.edu.uptc.driver.service.DriverService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequestMapping("/driver")
public class DriverController {

    @Autowired
    private DriverService driverService;

    @PostMapping("/saveVehicule")
    public ResponseEntity<DriverDTO> saveVehicule(@RequestBody DriverDTO driverDTO){
        DriverDTO savedDriver = driverService.saveVehicule(driverDTO);
        return new ResponseEntity<>(savedDriver, HttpStatus.OK);
    }

    @PostMapping("/updateVehicule")
    public ResponseEntity<DriverDTO> updateVehicule(@RequestBody DriverDTO driverDTO) {
        DriverDTO updatedDriver = driverService.updateVehicule(driverDTO);
        return new ResponseEntity<>(updatedDriver, HttpStatus.OK);
    }
    
    
}
