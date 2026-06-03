package co.edu.uptc.subscription.services;

import co.edu.uptc.subscription.dto.SubscriptionPlanDTO;
import co.edu.uptc.subscription.models.SubscriptionPlan;
import co.edu.uptc.subscription.repositories.SubscriptionPlanRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class SubscriptionPlanService {
    
    @Autowired
    private SubscriptionPlanRepository planRepository;
    
    /**
     * Obtener todos los planes activos de un parqueadero específico
     */
    public List<SubscriptionPlanDTO> getActivePlansByParking(Long parkingId) {
        List<SubscriptionPlan> plans = planRepository.findByParkingIdAndIsActiveTrue(parkingId);
        return plans.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * Obtener todos los planes de un parqueadero (incluyendo inactivos)
     */
    public List<SubscriptionPlanDTO> getPlansByParking(Long parkingId) {
        List<SubscriptionPlan> plans = planRepository.findByParkingId(parkingId);
        return plans.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * Obtener todos los planes activos
     */
    public List<SubscriptionPlanDTO> getAllActivePlans() {
        List<SubscriptionPlan> plans = planRepository.findByIsActiveTrue();
        return plans.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * Obtener todos los planes (incluyendo inactivos)
     */
    public List<SubscriptionPlanDTO> getAllPlans() {
        List<SubscriptionPlan> plans = planRepository.findAll();
        return plans.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * Obtener un plan específico
     */
    public SubscriptionPlanDTO getPlanById(Long planId) throws Exception {
        SubscriptionPlan plan = planRepository.findById(planId)
            .orElseThrow(() -> new Exception("Plan no encontrado"));
        return toDTO(plan);
    }
    
    /**
     * Crear un nuevo plan para un parqueadero
     */
    @Transactional
    public SubscriptionPlanDTO createPlan(SubscriptionPlanDTO dto) throws Exception {
        // Validar que parkingId esté presente
        if (dto.getParkingId() == null) {
            throw new Exception("ParkingId es requerido para crear un plan");
        }
        
        // Validar que no exista un plan con ese nombre en ese parqueadero
        if (planRepository.findByParkingIdAndNameAndIsActiveTrue(dto.getParkingId(), dto.getName()).isPresent()) {
            throw new Exception("Ya existe un plan con ese nombre en este parqueadero");
        }
        
        SubscriptionPlan plan = new SubscriptionPlan();
        plan.setParkingId(dto.getParkingId());
        plan.setName(dto.getName());
        plan.setDescription(dto.getDescription());
        plan.setMonthlyPrice(dto.getMonthlyPrice());
        plan.setDiscountPercentage(dto.getDiscountPercentage());
        plan.setMaxDailyHours(dto.getMaxDailyHours());
        plan.setMonthlyHours(dto.getMonthlyHours());
        plan.setFeatures(dto.getFeatures());
        plan.setIsActive(true);
        
        SubscriptionPlan saved = planRepository.save(plan);
        log.info("Plan creado: {}", saved.getId());
        return toDTO(saved);
    }
    
    /**
     * Actualizar un plan
     */
    @Transactional
    public SubscriptionPlanDTO updatePlan(Long planId, SubscriptionPlanDTO dto) throws Exception {
        SubscriptionPlan plan = planRepository.findById(planId)
            .orElseThrow(() -> new Exception("Plan no encontrado"));
        
        plan.setDescription(dto.getDescription());
        plan.setMonthlyPrice(dto.getMonthlyPrice());
        plan.setDiscountPercentage(dto.getDiscountPercentage());
        plan.setMaxDailyHours(dto.getMaxDailyHours());
        plan.setMonthlyHours(dto.getMonthlyHours());
        plan.setFeatures(dto.getFeatures());
        plan.setIsActive(dto.getIsActive());
        
        SubscriptionPlan updated = planRepository.save(plan);
        log.info("Plan actualizado: {}", planId);
        return toDTO(updated);
    }
    
    /**
     * Desactivar un plan
     */
    @Transactional
    public void deactivatePlan(Long planId) throws Exception {
        SubscriptionPlan plan = planRepository.findById(planId)
            .orElseThrow(() -> new Exception("Plan no encontrado"));
        
        plan.setIsActive(false);
        planRepository.save(plan);
        log.info("Plan desactivado: {}", planId);
    }
    
    /**
     * Convertir SubscriptionPlan a DTO
     */
    private SubscriptionPlanDTO toDTO(SubscriptionPlan plan) {
        return new SubscriptionPlanDTO(
            plan.getId(),
            plan.getParkingId(),
            plan.getName(),
            plan.getDescription(),
            plan.getMonthlyPrice(),
            plan.getDiscountPercentage(),
            plan.getMaxDailyHours(),
            plan.getMonthlyHours(),
            plan.getFeatures(),
            plan.getIsActive(),
            plan.getCreatedAt(),
            plan.getUpdatedAt()
        );
    }
}
