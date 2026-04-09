package co.edu.uptc.driver.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import co.edu.uptc.driver.dto.OwnerDTO;
import co.edu.uptc.driver.service.OwnerService;

@RestController
@RequestMapping("/owner")
public class OwnerController {

    @Autowired
    private OwnerService ownerService;

    @GetMapping("/get/{id}")
    public ResponseEntity<OwnerDTO> getOwnerById(@PathVariable Long id) {
        OwnerDTO ownerDTO = ownerService.getOwnerById(id);
        return new ResponseEntity<>(ownerDTO, HttpStatus.OK);
    }

}
