package co.edu.uptc.subscription.services;

import co.edu.uptc.subscription.dto.CreateSubscriptionRequest;
import co.edu.uptc.subscription.dto.DriverSubscriptionDTO;
import co.edu.uptc.subscription.dto.SubscriptionDiscountDTO;
import co.edu.uptc.subscription.models.*;
import co.edu.uptc.subscription.repositories.DriverSubscriptionRepository;
import co.edu.uptc.subscription.repositories.SubscriptionPlanRepository;
import co.edu.uptc.subscription.repositories.SubscriptionTransactionRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Slf4j
public class SubscriptionService {
    
    @Autowired
    private DriverSubscriptionRepository driverSubscriptionRepository;
    
    @Autowired
    private SubscriptionPlanRepository subscriptionPlanRepository;
    
    @Autowired
    private SubscriptionTransactionRepository transactionRepository;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${easypark.user-service.url:http://localhost:8080}")
    private String userServiceUrl;
    
    /**
     * Crear una nueva suscripción para un conductor en un parqueadero específico
     */
    @Transactional
    public DriverSubscriptionDTO createSubscriptionByEmail(String driverEmail, Long parkingId, Long planId, 
                                                           String paymentMethod, Boolean autoRenew) throws Exception {
        log.info("Buscando driver con email: {}", driverEmail);
        
        // Buscar el driverId por email llamando al User Service
        Long driverId = findDriverIdByEmail(driverEmail);
        
        if (driverId == null) {
            throw new Exception("No se encontró conductor con el email: " + driverEmail);
        }
        
        log.info("Driver encontrado con ID: {}", driverId);
        
        // Crear la suscripción con el driverId encontrado
        CreateSubscriptionRequest request = new CreateSubscriptionRequest();
        request.setDriverId(driverId);
        request.setParkingId(parkingId);
        request.setPlanId(planId);
        request.setPaymentMethod(paymentMethod);
        request.setAutoRenew(autoRenew);
        
        return createSubscription(request);
    }

    private Long findDriverIdByEmail(String email) {
        try {
            log.info("Consultando User Service para obtener driverId del email: {}", email);
            String url = userServiceUrl + "/user/email/" + email;
            
            log.info("URL de consulta: {}", url);
            
            try {
                // Obtener el usuario como un Map genérico
                Map response = restTemplate.getForObject(url, Map.class);
                
                log.debug("Respuesta del User Service: {}", response);
                
                if (response != null && response.containsKey("userID")) {
                    Object userIdObj = response.get("userID");
                    Long userId = null;
                    
                    if (userIdObj instanceof Number) {
                        userId = ((Number) userIdObj).longValue();
                    } else if (userIdObj instanceof String) {
                        userId = Long.parseLong((String) userIdObj);
                    }
                    
                    log.info("✓ Driver encontrado con ID: {} para email: {}", userId, email);
                    return userId;
                } else {
                    log.error("✗ La respuesta no contiene 'userID'. Respuesta: {}", response);
                    return null;
                }
            } catch (org.springframework.web.client.HttpClientErrorException e) {
                log.error("✗ Error HTTP al consultar User Service ({}): {}", e.getStatusCode(), e.getMessage());
                return null;
            } catch (org.springframework.web.client.ResourceAccessException e) {
                log.error("✗ Error de conexión al User Service: {}", e.getMessage());
                return null;
            }
        } catch (Exception e) {
            log.error("✗ Error inesperado consultando User Service para email {}: {} - {}", email, e.getClass().getName(), e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    @Transactional
    public DriverSubscriptionDTO createSubscription(CreateSubscriptionRequest request) throws Exception {
        log.info("Creando suscripción para driver: {} en parking: {}", request.getDriverId(), request.getParkingId());
        
        // Validar que el plan existe
        SubscriptionPlan plan = subscriptionPlanRepository.findById(request.getPlanId())
            .orElseThrow(() -> new Exception("Plan de suscripción no encontrado"));
        
        // Validar que el conductor no tiene una suscripción activa en ese parqueadero
        Optional<DriverSubscription> existingActive = driverSubscriptionRepository
            .findByDriverIdAndParkingIdAndStatus(request.getDriverId(), request.getParkingId(), SubscriptionStatus.ACTIVE);
        
        if (existingActive.isPresent()) {
            throw new Exception("El conductor ya tiene una suscripción activa en este parqueadero");
        }
        
        // Crear nueva suscripción
        DriverSubscription subscription = new DriverSubscription();
        subscription.setDriverId(request.getDriverId());
        subscription.setParkingId(request.getParkingId());
        subscription.setPlan(plan);
        subscription.setStatus(SubscriptionStatus.ACTIVE);
        subscription.setStartDate(LocalDateTime.now());
        subscription.setEndDate(LocalDateTime.now().plusMonths(1));
        subscription.setRenewalDate(LocalDateTime.now().plusMonths(1));
        subscription.setAutoRenew(request.getAutoRenew() != null ? request.getAutoRenew() : true);
        subscription.setHoursUsedThisMonth(0);
        subscription.setPaymentMethod(PaymentMethod.valueOf(request.getPaymentMethod().toUpperCase()));
        subscription.setNextPaymentDate(LocalDateTime.now().plusMonths(1));
        
        DriverSubscription saved = driverSubscriptionRepository.save(subscription);
        
        // Registrar transacción de cobro inicial
        createTransaction(saved, TransactionType.CHARGE, plan.getMonthlyPrice(), 
            "Primer pago de suscripción: " + plan.getName());
        
        log.info("Suscripción creada exitosamente: {}", saved.getId());
        return toDTO(saved);
    }
    
    /**
     * Obtener suscripción activa de un conductor en un parqueadero específico
     */
    public DriverSubscriptionDTO getActiveSubscription(Long driverId, Long parkingId) throws Exception {
        DriverSubscription subscription = driverSubscriptionRepository
            .findByDriverIdAndParkingIdAndStatus(driverId, parkingId, SubscriptionStatus.ACTIVE)
            .orElseThrow(() -> new Exception("No hay suscripción activa para este conductor en este parqueadero"));
        
        return toDTO(subscription);
    }
    
    /**
     * Obtener todas las suscripciones de un conductor
     */
    public List<DriverSubscriptionDTO> getSubscriptionsByDriver(Long driverId) {
        List<DriverSubscription> subscriptions = driverSubscriptionRepository
            .findByDriverIdOrderByCreatedAtDesc(driverId);
        
        return subscriptions.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * Obtener descuento aplicable a un conductor en un parqueadero específico
     */
    public SubscriptionDiscountDTO getApplicableDiscount(Long driverId, Long parkingId) {
        Optional<DriverSubscription> subscription = driverSubscriptionRepository
            .findByDriverIdAndParkingIdAndStatus(driverId, parkingId, SubscriptionStatus.ACTIVE);
        
        if (subscription.isPresent()) {
            DriverSubscription sub = subscription.get();
            return new SubscriptionDiscountDTO(
                driverId,
                sub.getPlan().getDiscountPercentage(),
                true,
                sub.getPlan().getName()
            );
        }
        
        return new SubscriptionDiscountDTO(driverId, 0, false, "Sin suscripción");
    }
    
    /**
     * Verificar si un conductor puede hacer una reserva según su plan en un parqueadero específico
     */
    public boolean canReserve(Long driverId, Long parkingId, Integer estimatedHours) {
        Optional<DriverSubscription> subscription = driverSubscriptionRepository
            .findByDriverIdAndParkingIdAndStatus(driverId, parkingId, SubscriptionStatus.ACTIVE);
        
        if (!subscription.isPresent()) {
            return true; // Sin suscripción, puede reservar (sin descuento)
        }
        
        DriverSubscription sub = subscription.get();
        SubscriptionPlan plan = sub.getPlan();
        
        // Si el plan tiene límite de horas mensuales
        if (plan.getMonthlyHours() != null) {
            int hoursAvailable = plan.getMonthlyHours() - sub.getHoursUsedThisMonth();
            return hoursAvailable >= estimatedHours;
        }
        
        return true;
    }
    
    /**
     * Actualizar horas usadas en una reserva en un parqueadero específico
     */
    @Transactional
    public void updateHoursUsed(Long driverId, Long parkingId, Integer hours) {
        Optional<DriverSubscription> subscription = driverSubscriptionRepository
            .findByDriverIdAndParkingIdAndStatus(driverId, parkingId, SubscriptionStatus.ACTIVE);
        
        if (subscription.isPresent()) {
            DriverSubscription sub = subscription.get();
            sub.setHoursUsedThisMonth(sub.getHoursUsedThisMonth() + hours);
            driverSubscriptionRepository.save(sub);
            log.info("Horas actualizadas para suscripción {} en parking {}: {} horas", sub.getId(), parkingId, sub.getHoursUsedThisMonth());
        }
    }
    
    /**
     * Renovar una suscripción
     */
    @Transactional
    public DriverSubscriptionDTO renewSubscription(Long subscriptionId) throws Exception {
        DriverSubscription subscription = driverSubscriptionRepository.findById(subscriptionId)
            .orElseThrow(() -> new Exception("Suscripción no encontrada"));
        
        subscription.setStatus(SubscriptionStatus.ACTIVE);
        subscription.setStartDate(LocalDateTime.now());
        subscription.setEndDate(LocalDateTime.now().plusMonths(1));
        subscription.setRenewalDate(LocalDateTime.now().plusMonths(1));
        subscription.setHoursUsedThisMonth(0);
        subscription.setNextPaymentDate(LocalDateTime.now().plusMonths(1));
        
        DriverSubscription saved = driverSubscriptionRepository.save(subscription);
        
        // Registrar transacción de renovación
        createTransaction(saved, TransactionType.CHARGE, saved.getPlan().getMonthlyPrice(),
            "Renovación de suscripción: " + saved.getPlan().getName());
        
        log.info("Suscripción renovada: {}", subscriptionId);
        return toDTO(saved);
    }
    
    /**
     * Cancelar una suscripción
     */
    @Transactional
    public DriverSubscriptionDTO cancelSubscription(Long subscriptionId) throws Exception {
        DriverSubscription subscription = driverSubscriptionRepository.findById(subscriptionId)
            .orElseThrow(() -> new Exception("Suscripción no encontrada"));
        
        subscription.setStatus(SubscriptionStatus.CANCELLED);
        subscription.setAutoRenew(false);
        
        DriverSubscription saved = driverSubscriptionRepository.save(subscription);
        
        // Registrar transacción de cancelación (posible reembolso)
        createTransaction(saved, TransactionType.REFUND, BigDecimal.ZERO,
            "Cancelación de suscripción");
        
        log.info("Suscripción cancelada: {}", subscriptionId);
        return toDTO(saved);
    }
    
    /**
     * Pausar una suscripción
     */
    @Transactional
    public DriverSubscriptionDTO pauseSubscription(Long subscriptionId) throws Exception {
        DriverSubscription subscription = driverSubscriptionRepository.findById(subscriptionId)
            .orElseThrow(() -> new Exception("Suscripción no encontrada"));
        
        subscription.setStatus(SubscriptionStatus.PAUSED);
        
        DriverSubscription saved = driverSubscriptionRepository.save(subscription);
        log.info("Suscripción pausada: {}", subscriptionId);
        return toDTO(saved);
    }
    
    /**
     * Crear una transacción
     */
    @Transactional
    private void createTransaction(DriverSubscription subscription, TransactionType type, 
                                   BigDecimal amount, String description) {
        SubscriptionTransaction transaction = new SubscriptionTransaction();
        transaction.setDriverSubscription(subscription);
        transaction.setType(type);
        transaction.setAmount(amount);
        transaction.setDescription(description);
        transaction.setStatus(TransactionStatus.SUCCESS);
        transaction.setTransactionDate(LocalDateTime.now());
        
        transactionRepository.save(transaction);
        log.info("Transacción creada: {} - {} - {}", type, amount, description);
    }
    
    /**
     * Obtener todas las suscripciones de un parqueadero
     */
    public List<DriverSubscriptionDTO> getSubscriptionsByParking(Long parkingId) {
        List<DriverSubscription> subscriptions = driverSubscriptionRepository
            .findByParkingIdOrderByCreatedAtDesc(parkingId);
        
        return subscriptions.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }

    /**
     * Obtener suscripciones activas de un parqueadero
     */
    public List<DriverSubscriptionDTO> getActiveSubscriptionsByParking(Long parkingId) {
        List<DriverSubscription> subscriptions = driverSubscriptionRepository
            .findByParkingIdAndStatus(parkingId, SubscriptionStatus.ACTIVE);
        
        return subscriptions.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }

    /**
     * Convertir DriverSubscription a DTO
     */
    private DriverSubscriptionDTO toDTO(DriverSubscription subscription) {
        return new DriverSubscriptionDTO(
            subscription.getId(),
            subscription.getDriverId(),
            subscription.getParkingId(),
            subscription.getPlan().getId(),
            subscription.getPlan().getName(),
            subscription.getStatus().toString(),
            subscription.getStartDate(),
            subscription.getEndDate(),
            subscription.getRenewalDate(),
            subscription.getAutoRenew(),
            subscription.getHoursUsedThisMonth(),
            subscription.getPaymentMethod().toString(),
            subscription.getNextPaymentDate(),
            subscription.getCreatedAt(),
            subscription.getUpdatedAt()
        );
    }
}
