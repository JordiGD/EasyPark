package co.edu.uptc.parking.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import co.edu.uptc.parking.dto.SpaceDTO;
import co.edu.uptc.parking.service.SpaceService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import java.util.List;


@RestController
@RequestMapping("/api/spaces")
public class SpaceController {

    @Autowired
    private SpaceService spaceService;

    @PostMapping("/create/{parkingId}")
    public ResponseEntity<SpaceDTO> createSpace(@PathVariable Long parkingId) {
        SpaceDTO spaceDTO = spaceService.createSpace(parkingId);
        return new ResponseEntity<>(spaceDTO, HttpStatus.CREATED);
    }

    @GetMapping("/all")
    public ResponseEntity<List<SpaceDTO>> getSpaces() {
        List<SpaceDTO> spaces = spaceService.getSpaces();
        return new ResponseEntity<>(spaces, HttpStatus.OK);
    }

    @GetMapping("/parking/{parkingId}")
    public ResponseEntity<List<SpaceDTO>> getSpacesByParkingId(@PathVariable Long parkingId) {
        List<SpaceDTO> spaces = spaceService.getSpacesByParkingId(parkingId);
        return new ResponseEntity<>(spaces, HttpStatus.OK);
    }

    @GetMapping("/{spaceId}/status")
    public ResponseEntity<String> getSpaceStatusById(@PathVariable Long spaceId) {
        String status = spaceService.getSpaceStatusById(spaceId);
        if (!status.equals("Space not found")) {
            return new ResponseEntity<>(status, HttpStatus.OK);
        }
        return new ResponseEntity<>(status, HttpStatus.NOT_FOUND);
    }

    @PutMapping("/{spaceId}/status")
    public ResponseEntity<String> updateSpaceStatus(@PathVariable Long spaceId, @RequestBody String status) {
        boolean updated = spaceService.updateSpaceStatus(spaceId, status);
        
        if (updated) {
            return new ResponseEntity<>("Space status updated successfully", HttpStatus.OK);
        }
        
        return new ResponseEntity<>("Space not found", HttpStatus.NOT_FOUND);
    }
    
}

