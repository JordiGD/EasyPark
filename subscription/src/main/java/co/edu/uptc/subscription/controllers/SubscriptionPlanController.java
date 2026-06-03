package co.edu.uptc.subscription.controllers;

import co.edu.uptc.subscription.dto.SubscriptionPlanDTO;
import co.edu.uptc.subscription.services.SubscriptionPlanService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/subscriptions/plans")
@Slf4j
@CrossOrigin(origins = "http://localhost:*", maxAge = 3600)
public class SubscriptionPlanController {
    
    @Autowired
    private SubscriptionPlanService planService;
    
    /**
     * GET /api/subscriptions/plans - Obtener todos los planes activos
     */
    @GetMapping
    public ResponseEntity<List<SubscriptionPlanDTO>> getAllActivePlans() {
        log.info("Obteniendo todos los planes activos");
        List<SubscriptionPlanDTO> plans = planService.getAllActivePlans();
        return ResponseEntity.ok(plans);
    }

    /**
     * GET /api/subscriptions/plans/parking/{parkingId} - Obtener planes activos de un parqueadero
     */
    @GetMapping("/parking/{parkingId}")
    public ResponseEntity<List<SubscriptionPlanDTO>> getActivePlansByParking(@PathVariable Long parkingId) {
        log.info("Obteniendo planes activos para parking: {}", parkingId);
        List<SubscriptionPlanDTO> plans = planService.getActivePlansByParking(parkingId);
        return ResponseEntity.ok(plans);
    }
    
    /**
     * GET /api/subscriptions/plans/all - Obtener todos los planes (incluyendo inactivos)
     */
    @GetMapping("/all")
    public ResponseEntity<List<SubscriptionPlanDTO>> getAllPlans() {
        log.info("Obteniendo todos los planes");
        List<SubscriptionPlanDTO> plans = planService.getAllPlans();
        return ResponseEntity.ok(plans);
    }
    
    /**
     * GET /api/subscriptions/plans/{id} - Obtener un plan específico
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getPlanById(@PathVariable Long id) {
        try {
            log.info("Obteniendo plan: {}", id);
            SubscriptionPlanDTO plan = planService.getPlanById(id);
            return ResponseEntity.ok(plan);
        } catch (Exception e) {
            log.error("Error obteniendo plan: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    /**
     * POST /api/subscriptions/plans - Crear un nuevo plan
     */
    @PostMapping
    public ResponseEntity<?> createPlan(@RequestBody SubscriptionPlanDTO dto) {
        try {
            log.info("Creando nuevo plan: {}", dto.getName());
            SubscriptionPlanDTO plan = planService.createPlan(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(plan);
        } catch (Exception e) {
            log.error("Error creando plan: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    /**
     * PUT /api/subscriptions/plans/{id} - Actualizar un plan
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePlan(@PathVariable Long id, @RequestBody SubscriptionPlanDTO dto) {
        try {
            log.info("Actualizando plan: {}", id);
            SubscriptionPlanDTO plan = planService.updatePlan(id, dto);
            return ResponseEntity.ok(plan);
        } catch (Exception e) {
            log.error("Error actualizando plan: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    /**
     * DELETE /api/subscriptions/plans/{id} - Desactivar un plan
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deactivatePlan(@PathVariable Long id) {
        try {
            log.info("Desactivando plan: {}", id);
            planService.deactivatePlan(id);
            return ResponseEntity.ok("Plan desactivado correctamente");
        } catch (Exception e) {
            log.error("Error desactivando plan: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}
