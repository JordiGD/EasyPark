package co.edu.uptc.reservation.services;

import co.edu.uptc.reservation.client.SpaceClient;
import co.edu.uptc.reservation.dto.CreateReservationRequest;
import co.edu.uptc.reservation.dto.ReservationDTO;
import co.edu.uptc.reservation.models.Reservation;
import co.edu.uptc.reservation.models.ReservationStatus;
import co.edu.uptc.reservation.repositories.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationService {
    
    private static final Logger logger = LoggerFactory.getLogger(ReservationService.class);
    
    private final ReservationRepository reservationRepository;
    private final SpaceClient spaceClient;
    
    @Transactional
    public ReservationDTO createReservation(CreateReservationRequest request) {
        Reservation reservation = new Reservation();
        reservation.setDriverId(request.getDriverId());
        reservation.setSpaceId(request.getSpaceId());
        reservation.setParkingId(request.getParkingId());
        reservation.setStartTime(request.getStartTime());
        reservation.setStatus(ReservationStatus.ACTIVE);
        
        Reservation saved = reservationRepository.save(reservation);
        
        // Actualizar estado del espacio a OCCUPIED
        boolean statusUpdated = spaceClient.updateSpaceStatus(request.getSpaceId(), "OCCUPIED");
        if (statusUpdated) {
            logger.info("Espacio {} marcado como OCCUPIED para la reserva {}", request.getSpaceId(), saved.getId());
        } else {
            logger.warn("No se pudo actualizar el estado del espacio {} a OCCUPIED", request.getSpaceId());
        }
        
        return mapToDTO(saved);
    }
    
    @Transactional(readOnly = true)
    public ReservationDTO getReservationById(Long id) {
        Reservation reservation = reservationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));
        return mapToDTO(reservation);
    }
    
    @Transactional(readOnly = true)
    public List<ReservationDTO> getReservationsByDriver(Long driverId) {
        return reservationRepository.findByDriverId(driverId)
            .stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<ReservationDTO> getReservationsByParking(Long parkingId) {
        return reservationRepository.findByParkingId(parkingId)
            .stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<ReservationDTO> getActiveReservationsByDriver(Long driverId) {
        return reservationRepository.findByDriverIdAndStatus(driverId, ReservationStatus.ACTIVE)
            .stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional
    public ReservationDTO cancelReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));
        
        if (!reservation.getStatus().equals(ReservationStatus.ACTIVE)) {
            throw new RuntimeException("Solo se pueden cancelar reservas activas");
        }
        
        reservation.setStatus(ReservationStatus.CANCELLED);
        Reservation updated = reservationRepository.save(reservation);
        
        // Actualizar estado del espacio a AVAILABLE
        boolean statusUpdated = spaceClient.updateSpaceStatus(reservation.getSpaceId(), "AVAILABLE");
        if (statusUpdated) {
            logger.info("Espacio {} marcado como AVAILABLE después de cancelar reserva {}", reservation.getSpaceId(), id);
        } else {
            logger.warn("No se pudo actualizar el estado del espacio {} a AVAILABLE", reservation.getSpaceId());
        }
        
        return mapToDTO(updated);
    }
    
    @Transactional
    public ReservationDTO completeReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));
        
        reservation.setStatus(ReservationStatus.COMPLETED);
        Reservation updated = reservationRepository.save(reservation);
        
        // Actualizar estado del espacio a AVAILABLE cuando se completa la reserva
        boolean statusUpdated = spaceClient.updateSpaceStatus(reservation.getSpaceId(), "AVAILABLE");
        if (statusUpdated) {
            logger.info("Espacio {} marcado como AVAILABLE después de completar reserva {}", reservation.getSpaceId(), id);
        } else {
            logger.warn("No se pudo actualizar el estado del espacio {} a AVAILABLE", reservation.getSpaceId());
        }
        
        return mapToDTO(updated);
    }
    
    @Transactional(readOnly = true)
    public List<ReservationDTO> getReservationsBySpace(Long spaceId) {
        return reservationRepository.findBySpaceId(spaceId)
            .stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
    
    private ReservationDTO mapToDTO(Reservation reservation) {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(reservation.getId());
        dto.setDriverId(reservation.getDriverId());
        dto.setSpaceId(reservation.getSpaceId());
        dto.setParkingId(reservation.getParkingId());
        dto.setStatus(reservation.getStatus().toString());
        dto.setStartTime(reservation.getStartTime());
        dto.setCreatedAt(reservation.getCreatedAt());
        dto.setUpdatedAt(reservation.getUpdatedAt());
        return dto;
    }
}
