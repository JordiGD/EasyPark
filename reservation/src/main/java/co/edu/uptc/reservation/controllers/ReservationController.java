package co.edu.uptc.reservation.controllers;

import co.edu.uptc.reservation.dto.CreateReservationRequest;
import co.edu.uptc.reservation.dto.ReservationDTO;
import co.edu.uptc.reservation.services.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {
    
    private final ReservationService reservationService;
    
    @PostMapping
    public ResponseEntity<ReservationDTO> createReservation(@RequestBody CreateReservationRequest request) {
        ReservationDTO reservation = reservationService.createReservation(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(reservation);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ReservationDTO> getReservation(@PathVariable Long id) {
        ReservationDTO reservation = reservationService.getReservationById(id);
        return ResponseEntity.ok(reservation);
    }
    
    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<ReservationDTO>> getReservationsByDriver(@PathVariable Long driverId) {
        List<ReservationDTO> reservations = reservationService.getReservationsByDriver(driverId);
        return ResponseEntity.ok(reservations);
    }
    
    @GetMapping("/driver/{driverId}/active")
    public ResponseEntity<List<ReservationDTO>> getActiveReservationsByDriver(@PathVariable Long driverId) {
        List<ReservationDTO> reservations = reservationService.getActiveReservationsByDriver(driverId);
        return ResponseEntity.ok(reservations);
    }
    
    @GetMapping("/parking/{parkingId}")
    public ResponseEntity<List<ReservationDTO>> getReservationsByParking(@PathVariable Long parkingId) {
        List<ReservationDTO> reservations = reservationService.getReservationsByParking(parkingId);
        return ResponseEntity.ok(reservations);
    }
    
    @GetMapping("/space/{spaceId}")
    public ResponseEntity<List<ReservationDTO>> getReservationsBySpace(@PathVariable Long spaceId) {
        List<ReservationDTO> reservations = reservationService.getReservationsBySpace(spaceId);
        return ResponseEntity.ok(reservations);
    }
    
    @PutMapping("/{id}/cancel")
    public ResponseEntity<ReservationDTO> cancelReservation(@PathVariable Long id) {
        ReservationDTO reservation = reservationService.cancelReservation(id);
        return ResponseEntity.ok(reservation);
    }
    
    @PutMapping("/{id}/complete")
    public ResponseEntity<ReservationDTO> completeReservation(@PathVariable Long id) {
        ReservationDTO reservation = reservationService.completeReservation(id);
        return ResponseEntity.ok(reservation);
    }
}
