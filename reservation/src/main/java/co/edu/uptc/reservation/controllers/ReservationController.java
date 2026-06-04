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
        return ResponseEntity.status(HttpStatus.CREATED).body(reservationService.createReservation(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservationDTO> getReservation(@PathVariable Long id) {
        return ResponseEntity.ok(reservationService.getReservationById(id));
    }

    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<ReservationDTO>> getReservationsByDriver(@PathVariable Long driverId) {
        return ResponseEntity.ok(reservationService.getReservationsByDriver(driverId));
    }

    @GetMapping("/driver/{driverId}/active")
    public ResponseEntity<List<ReservationDTO>> getActiveReservationsByDriver(@PathVariable Long driverId) {
        return ResponseEntity.ok(reservationService.getActiveReservationsByDriver(driverId));
    }

    @GetMapping("/parking/{parkingId}")
    public ResponseEntity<List<ReservationDTO>> getReservationsByParking(@PathVariable Long parkingId) {
        return ResponseEntity.ok(reservationService.getReservationsByParking(parkingId));
    }

    @GetMapping("/space/{spaceId}")
    public ResponseEntity<List<ReservationDTO>> getReservationsBySpace(@PathVariable Long spaceId) {
        return ResponseEntity.ok(reservationService.getReservationsBySpace(spaceId));
    }

    /** Conductor confirma su llegada al parqueadero */
    @PutMapping("/{id}/driver-confirm")
    public ResponseEntity<ReservationDTO> driverConfirmArrival(@PathVariable Long id) {
        return ResponseEntity.ok(reservationService.driverConfirmArrival(id));
    }

    /** Propietario confirma la llegada del conductor */
    @PutMapping("/{id}/owner-confirm")
    public ResponseEntity<ReservationDTO> ownerConfirmArrival(@PathVariable Long id) {
        return ResponseEntity.ok(reservationService.ownerConfirmArrival(id));
    }

    /** Propietario cancela la reserva (solo disponible después de 15 minutos) */
    @PutMapping("/{id}/cancel")
    public ResponseEntity<ReservationDTO> cancelReservation(@PathVariable Long id) {
        return ResponseEntity.ok(reservationService.cancelReservation(id));
    }

    /** Completar reserva tras pago (llamado por payment-service) */
    @PutMapping("/{id}/complete")
    public ResponseEntity<ReservationDTO> completeReservation(@PathVariable Long id) {
        return ResponseEntity.ok(reservationService.completeReservation(id));
    }

    /** Marcar como facturada (llamado por payment-service) */
    @PutMapping("/{id}/invoiced")
    public ResponseEntity<ReservationDTO> markAsInvoiced(@PathVariable Long id) {
        return ResponseEntity.ok(reservationService.markAsInvoiced(id));
    }
}
