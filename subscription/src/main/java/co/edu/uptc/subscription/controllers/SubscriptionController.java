package co.edu.uptc.subscription.controllers;

import co.edu.uptc.subscription.dto.CreateSubscriptionRequest;
import co.edu.uptc.subscription.dto.DriverSubscriptionDTO;
import co.edu.uptc.subscription.dto.SubscriptionDiscountDTO;
import co.edu.uptc.subscription.dto.SubscriptionByEmailRequest;
import co.edu.uptc.subscription.services.SubscriptionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/subscriptions")
@Slf4j
@CrossOrigin(origins = "http://localhost:*", maxAge = 3600)
public class SubscriptionController {
    
    @Autowired
    private SubscriptionService subscriptionService;
    
    /**
     * POST /api/subscriptions/by-email - Crear suscripción usando email del driver
     */
    @PostMapping("/by-email")
    public ResponseEntity<?> createSubscriptionByEmail(@RequestBody SubscriptionByEmailRequest request) {
        try {
            log.info("Creando suscripción para driver con email: {}", request.getDriverEmail());
            DriverSubscriptionDTO subscription = subscriptionService.createSubscriptionByEmail(
                request.getDriverEmail(),
                request.getParkingId(),
                request.getPlanId(),
                request.getPaymentMethod(),
                request.getAutoRenew()
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(subscription);
        } catch (Exception e) {
            log.error("Error creando suscripción por email: {}", e.getMessage());
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    /**
     * POST /api/subscriptions - Crear una nueva suscripción
     */
    @PostMapping
    public ResponseEntity<?> createSubscription(@RequestBody CreateSubscriptionRequest request) {
        try {
            log.info("Creando suscripción para driver: {}", request.getDriverId());
            DriverSubscriptionDTO subscription = subscriptionService.createSubscription(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(subscription);
        } catch (Exception e) {
            log.error("Error creando suscripción: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    /**
     * GET /api/subscriptions/driver/{driverId}/active?parkingId={parkingId} - Obtener suscripción activa en un parqueadero
     */
    @GetMapping("/driver/{driverId}/active")
    public ResponseEntity<?> getActiveSubscription(@PathVariable Long driverId, @RequestParam Long parkingId) {
        try {
            log.info("Obteniendo suscripción activa para driver: {} en parking: {}", driverId, parkingId);
            DriverSubscriptionDTO subscription = subscriptionService.getActiveSubscription(driverId, parkingId);
            return ResponseEntity.ok(subscription);
        } catch (Exception e) {
            log.error("Error obteniendo suscripción activa: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    /**
     * GET /api/subscriptions/driver/{driverId} - Obtener todas las suscripciones del driver
     */
    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<DriverSubscriptionDTO>> getDriverSubscriptions(@PathVariable Long driverId) {
        log.info("Obteniendo suscripciones para driver: {}", driverId);
        List<DriverSubscriptionDTO> subscriptions = subscriptionService.getSubscriptionsByDriver(driverId);
        return ResponseEntity.ok(subscriptions);
    }
    
    /**
     * GET /api/subscriptions/driver/{driverId}/discount?parkingId={parkingId} - Obtener descuento aplicable
     */
    @GetMapping("/driver/{driverId}/discount")
    public ResponseEntity<SubscriptionDiscountDTO> getApplicableDiscount(@PathVariable Long driverId, @RequestParam Long parkingId) {
        log.info("Obteniendo descuento para driver: {} en parking: {}", driverId, parkingId);
        SubscriptionDiscountDTO discount = subscriptionService.getApplicableDiscount(driverId, parkingId);
        return ResponseEntity.ok(discount);
    }
    
    /**
     * POST /api/subscriptions/{id}/renew - Renovar suscripción
     */
    @PostMapping("/{id}/renew")
    public ResponseEntity<?> renewSubscription(@PathVariable Long id) {
        try {
            log.info("Renovando suscripción: {}", id);
            DriverSubscriptionDTO subscription = subscriptionService.renewSubscription(id);
            return ResponseEntity.ok(subscription);
        } catch (Exception e) {
            log.error("Error renovando suscripción: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    /**
     * PUT /api/subscriptions/{id}/cancel - Cancelar suscripción
     */
    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancelSubscription(@PathVariable Long id) {
        try {
            log.info("Cancelando suscripción: {}", id);
            DriverSubscriptionDTO subscription = subscriptionService.cancelSubscription(id);
            return ResponseEntity.ok(subscription);
        } catch (Exception e) {
            log.error("Error cancelando suscripción: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    /**
     * PUT /api/subscriptions/{id}/pause - Pausar suscripción
     */
    @PutMapping("/{id}/pause")
    public ResponseEntity<?> pauseSubscription(@PathVariable Long id) {
        try {
            log.info("Pausando suscripción: {}", id);
            DriverSubscriptionDTO subscription = subscriptionService.pauseSubscription(id);
            return ResponseEntity.ok(subscription);
        } catch (Exception e) {
            log.error("Error pausando suscripción: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    /**
     * GET /api/subscriptions/driver/{driverId}/can-reserve?parkingId={parkingId}&estimatedHours={hours} - Verificar si puede reservar
     */
    @GetMapping("/driver/{driverId}/can-reserve")
    public ResponseEntity<Boolean> canReserve(@PathVariable Long driverId,
                                              @RequestParam Long parkingId,
                                              @RequestParam Integer estimatedHours) {
        log.info("Verificando si driver {} puede reservar {} horas en parking {}", driverId, estimatedHours, parkingId);
        boolean canReserve = subscriptionService.canReserve(driverId, parkingId, estimatedHours);
        return ResponseEntity.ok(canReserve);
    }

    /**
     * GET /api/subscriptions/parking/{parkingId} - Obtener todas las suscripciones de un parqueadero
     */
    @GetMapping("/parking/{parkingId}")
    public ResponseEntity<List<DriverSubscriptionDTO>> getSubscriptionsByParking(@PathVariable Long parkingId) {
        log.info("Obteniendo suscripciones para parking: {}", parkingId);
        List<DriverSubscriptionDTO> subscriptions = subscriptionService.getSubscriptionsByParking(parkingId);
        return ResponseEntity.ok(subscriptions);
    }

    /**
     * GET /api/subscriptions/parking/{parkingId}/active - Obtener suscripciones activas de un parqueadero
     */
    @GetMapping("/parking/{parkingId}/active")
    public ResponseEntity<List<DriverSubscriptionDTO>> getActiveSubscriptionsByParking(@PathVariable Long parkingId) {
        log.info("Obteniendo suscripciones activas para parking: {}", parkingId);
        List<DriverSubscriptionDTO> subscriptions = subscriptionService.getActiveSubscriptionsByParking(parkingId);
        return ResponseEntity.ok(subscriptions);
    }
}
