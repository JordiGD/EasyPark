package co.edu.uptc.reservation.services;

import co.edu.uptc.reservation.client.NotificationClient;
import co.edu.uptc.reservation.client.SpaceClient;
import co.edu.uptc.reservation.dto.CreateReservationRequest;
import co.edu.uptc.reservation.dto.ReservationDTO;
import co.edu.uptc.reservation.models.Reservation;
import co.edu.uptc.reservation.models.ReservationStatus;
import co.edu.uptc.reservation.repositories.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private static final Logger logger = LoggerFactory.getLogger(ReservationService.class);

    private final ReservationRepository reservationRepository;
    private final SpaceClient spaceClient;
    private final NotificationClient notificationClient;

    @Transactional
    public ReservationDTO createReservation(CreateReservationRequest request) {
        Reservation reservation = new Reservation();
        reservation.setDriverId(request.getDriverId());
        reservation.setSpaceId(request.getSpaceId());
        reservation.setParkingId(request.getParkingId());
        reservation.setStartTime(request.getStartTime());
        reservation.setStatus(ReservationStatus.ACTIVE);

        Reservation saved = reservationRepository.save(reservation);

        boolean statusUpdated = spaceClient.updateSpaceStatus(request.getSpaceId(), "OCCUPIED");
        if (!statusUpdated) {
            logger.warn("No se pudo actualizar el estado del espacio {} a OCCUPIED", request.getSpaceId());
        }

        notificationClient.sendNotification(
                "RESERVATION_CREATED",
                saved.getDriverId(),
                "DRIVER",
                "Tu reserva fue creada. Tienes 15 minutos para llegar al parqueadero.",
                saved.getId());

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
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ReservationDTO> getReservationsByParking(Long parkingId) {
        return reservationRepository.findByParkingId(parkingId)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ReservationDTO> getActiveReservationsByDriver(Long driverId) {
        return reservationRepository.findByDriverIdAndStatus(driverId, ReservationStatus.ACTIVE)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ReservationDTO> getReservationsBySpace(Long spaceId) {
        return reservationRepository.findBySpaceId(spaceId)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /** Conductor confirma llegada al parqueadero */
    @Transactional
    public ReservationDTO driverConfirmArrival(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        if (!reservation.getStatus().equals(ReservationStatus.ACTIVE)) {
            throw new RuntimeException("Solo se puede confirmar llegada en reservas activas");
        }

        reservation.setStatus(ReservationStatus.DRIVER_CONFIRMED);
        reservation.setDriverConfirmedAt(LocalDateTime.now());
        Reservation updated = reservationRepository.save(reservation);

        notificationClient.sendNotification(
                "DRIVER_ARRIVED",
                updated.getParkingId(),
                "OWNER",
                "El conductor ha llegado al parqueadero. Por favor confirma su llegada.",
                updated.getId());

        return mapToDTO(updated);
    }

    /** Propietario confirma llegada del conductor */
    @Transactional
    public ReservationDTO ownerConfirmArrival(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        if (!reservation.getStatus().equals(ReservationStatus.DRIVER_CONFIRMED)) {
            throw new RuntimeException("Solo se puede confirmar cuando el conductor ya confirmó su llegada");
        }

        reservation.setStatus(ReservationStatus.OWNER_CONFIRMED);
        reservation.setOwnerConfirmedAt(LocalDateTime.now());
        Reservation updated = reservationRepository.save(reservation);

        notificationClient.sendNotification(
                "BOTH_CONFIRMED",
                updated.getDriverId(),
                "DRIVER",
                "El propietario confirmó tu llegada. Espera la factura para proceder al pago.",
                updated.getId());

        return mapToDTO(updated);
    }

    /** Propietario cancela la reserva — solo permitido después de los 15 minutos si el conductor no llegó */
    @Transactional
    public ReservationDTO cancelReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        if (!reservation.getStatus().equals(ReservationStatus.ACTIVE)) {
            throw new RuntimeException("Solo se pueden cancelar reservas activas donde el conductor no llegó");
        }

        if (LocalDateTime.now().isBefore(reservation.getArrivalDeadline())) {
            throw new RuntimeException("Aún está dentro del período de 15 minutos. No puedes cancelar todavía.");
        }

        reservation.setStatus(ReservationStatus.CANCELLED);
        Reservation updated = reservationRepository.save(reservation);

        spaceClient.updateSpaceStatus(reservation.getSpaceId(), "AVAILABLE");

        notificationClient.sendNotification(
                "RESERVATION_CANCELLED",
                updated.getDriverId(),
                "DRIVER",
                "Tu reserva fue cancelada porque no llegaste dentro del tiempo límite.",
                updated.getId());

        return mapToDTO(updated);
    }

    /** Marca la reserva como INVOICED (llamado por el payment-service al generar factura) */
    @Transactional
    public ReservationDTO markAsInvoiced(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        if (!reservation.getStatus().equals(ReservationStatus.OWNER_CONFIRMED)) {
            throw new RuntimeException("La factura solo puede generarse cuando ambos confirmaron la llegada");
        }

        reservation.setStatus(ReservationStatus.INVOICED);
        return mapToDTO(reservationRepository.save(reservation));
    }

    /** Completa la reserva tras el pago (llamado por el payment-service) */
    @Transactional
    public ReservationDTO completeReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        reservation.setStatus(ReservationStatus.COMPLETED);
        Reservation updated = reservationRepository.save(reservation);

        spaceClient.updateSpaceStatus(reservation.getSpaceId(), "AVAILABLE");

        notificationClient.sendNotification(
                "PAYMENT_COMPLETED",
                updated.getDriverId(),
                "DRIVER",
                "Tu pago fue procesado exitosamente. ¡Gracias por usar EasyPark!",
                updated.getId());

        return mapToDTO(updated);
    }

    /** Scheduler que expira reservas ACTIVE cuyo plazo de llegada ya venció */
    @Scheduled(fixedDelay = 60000)
    @Transactional
    public void expireOverdueReservations() {
        List<Reservation> expired = reservationRepository
                .findExpiredActiveReservations(ReservationStatus.ACTIVE, LocalDateTime.now());

        for (Reservation r : expired) {
            r.setStatus(ReservationStatus.EXPIRED);
            reservationRepository.save(r);
            spaceClient.updateSpaceStatus(r.getSpaceId(), "AVAILABLE");
            logger.info("Reserva {} expirada automáticamente", r.getId());
        }
    }

    private ReservationDTO mapToDTO(Reservation r) {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(r.getId());
        dto.setDriverId(r.getDriverId());
        dto.setSpaceId(r.getSpaceId());
        dto.setParkingId(r.getParkingId());
        dto.setStatus(r.getStatus().toString());
        dto.setStartTime(r.getStartTime());
        dto.setArrivalDeadline(r.getArrivalDeadline());
        dto.setDriverConfirmedAt(r.getDriverConfirmedAt());
        dto.setOwnerConfirmedAt(r.getOwnerConfirmedAt());
        dto.setCreatedAt(r.getCreatedAt());
        dto.setUpdatedAt(r.getUpdatedAt());
        dto.setCanOwnerCancel(r.getStatus() == ReservationStatus.ACTIVE
                && LocalDateTime.now().isAfter(r.getArrivalDeadline()));
        dto.setCanGenerateInvoice(r.getStatus() == ReservationStatus.OWNER_CONFIRMED);
        return dto;
    }
}
