package co.edu.uptc.parking.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import co.edu.uptc.parking.dto.ParkingDTO;
import co.edu.uptc.parking.dto.CreateParkingRequest;
import co.edu.uptc.parking.service.ParkingService;

@RestController
@RequestMapping("/api/parkings")
public class ParkingController {

    @Autowired
    private ParkingService parkingService;

    @PostMapping
    public ResponseEntity<?> createParking(@RequestBody CreateParkingRequest request) {
        try {
            ParkingDTO createdParking = parkingService.saveParking(request);
            return new ResponseEntity<>(createdParking, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(
                    new ErrorResponse("Error de validación", e.getMessage()),
                    HttpStatus.BAD_REQUEST
            );
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ParkingDTO> getParkingById(@PathVariable Long id) {
        ParkingDTO parking = parkingService.getParkingById(id);
        if (parking != null) {
            return new ResponseEntity<>(parking, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @GetMapping
    public ResponseEntity<List<ParkingDTO>> getAllParkings() {
        List<ParkingDTO> parkings = parkingService.getAllParkings();
        return new ResponseEntity<>(parkings, HttpStatus.OK);
    }

    @GetMapping("/owner/{ownerId}")
    public ResponseEntity<List<ParkingDTO>> getParkingsByOwner(@PathVariable Long ownerId) {
        List<ParkingDTO> parkings = parkingService.getParkingByOwnerId(ownerId);
        if (!parkings.isEmpty()) {
            return new ResponseEntity<>(parkings, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateParking(@PathVariable Long id, @RequestBody ParkingDTO parkingDTO) {
        try {
            ParkingDTO updatedParking = parkingService.updateParking(id, parkingDTO);
            if (updatedParking != null) {
                return new ResponseEntity<>(updatedParking, HttpStatus.OK);
            }
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(
                    new ErrorResponse("Error de geocodificación", e.getMessage()),
                    HttpStatus.BAD_REQUEST
            );
        }
    }

    @GetMapping("/{id}/status")
    public ResponseEntity<Boolean> getStatusParkingById(@PathVariable Long id) {
        boolean status = parkingService.getStatusParkingById(id);
        return new ResponseEntity<>(status, HttpStatus.OK);
    }

    @GetMapping("/nearby")
    public ResponseEntity<List<ParkingDTO>> getParkingsNearby(
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(defaultValue = "5") double radiusKm) {
        List<ParkingDTO> parkings = parkingService.getParkingsNearby(latitude, longitude, radiusKm);
        return new ResponseEntity<>(parkings, HttpStatus.OK);
    }

    @GetMapping("/map/all")
    public ResponseEntity<List<ParkingDTO>> getAllParkingsForMap() {
        List<ParkingDTO> parkings = parkingService.getAllParkings();
        return new ResponseEntity<>(parkings, HttpStatus.OK);
    }

}
