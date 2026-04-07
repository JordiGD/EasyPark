package co.edu.uptc.driver.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.service.OwnerService;

@RestController
@RequestMapping("/owner")
public class OwnerController {

    @Autowired
    private OwnerService ownerService;

    @PostMapping("/saveParking")
    public ResponseEntity<OwnerDTO> saveParking(@RequestBody OwnerDTO ownerDTO) {
        OwnerDTO savedOwner = ownerService.saveParking(ownerDTO);
        return new ResponseEntity<>(savedOwner, HttpStatus.OK);
    }

    @PostMapping("/updateParking")
    public ResponseEntity<OwnerDTO> updateParking(@RequestBody OwnerDTO ownerDTO) {
        OwnerDTO updatedOwner = ownerService.updateParking(ownerDTO);
        return new ResponseEntity<>(updatedOwner, HttpStatus.OK);
    }

}
