package co.edu.uptc.payment.service;

import co.edu.uptc.payment.client.NotificationClient;
import co.edu.uptc.payment.client.ReservationClient;
import co.edu.uptc.payment.dto.CreateInvoiceRequest;
import co.edu.uptc.payment.dto.InvoiceDTO;
import co.edu.uptc.payment.model.Invoice;
import co.edu.uptc.payment.model.InvoiceStatus;
import co.edu.uptc.payment.repository.InvoiceRepository;
import com.mercadopago.client.preference.PreferenceClient;
import com.mercadopago.client.preference.PreferenceItemRequest;
import com.mercadopago.client.preference.PreferenceRequest;
import com.mercadopago.client.preference.PreferenceBackUrlsRequest;
import com.mercadopago.resources.preference.Preference;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private static final Logger logger = LoggerFactory.getLogger(InvoiceService.class);

    private final InvoiceRepository invoiceRepository;
    private final ReservationClient reservationClient;
    private final NotificationClient notificationClient;

    @Value("${app.success-url}")
    private String successUrl;

    @Value("${app.failure-url}")
    private String failureUrl;

    @Value("${app.pending-url}")
    private String pendingUrl;

    /** Propietario genera una factura para una reserva con ambas confirmaciones */
    @Transactional
    public InvoiceDTO createInvoice(CreateInvoiceRequest request) {
        // Verificar que no exista ya una factura para esta reserva
        invoiceRepository.findByReservationId(request.getReservationId()).ifPresent(existing -> {
            throw new RuntimeException("Ya existe una factura para esta reserva");
        });

        Invoice invoice = new Invoice();
        invoice.setReservationId(request.getReservationId());
        invoice.setDriverId(request.getDriverId());
        invoice.setOwnerId(request.getOwnerId());
        invoice.setParkingId(request.getParkingId());
        invoice.setAmount(request.getAmount());
        invoice.setDescription(request.getDescription() != null
                ? request.getDescription()
                : "Pago de parqueadero - Reserva #" + request.getReservationId());

        // Crear preferencia en MercadoPago
        try {
            PreferenceItemRequest item = PreferenceItemRequest.builder()
                    .title(invoice.getDescription())
                    .quantity(1)
                    .unitPrice(request.getAmount())
                    .currencyId("COP")
                    .build();

            PreferenceRequest.PreferenceRequestBuilder preferenceBuilder = PreferenceRequest.builder()
                    .items(List.of(item))
                    .externalReference(String.valueOf(request.getReservationId()));

            // Solo agregar backUrls si no son localhost (MP las rechaza en producción)
            boolean isLocalhost = successUrl.contains("localhost") || successUrl.contains("127.0.0.1");
            if (!isLocalhost) {
                PreferenceBackUrlsRequest backUrls = PreferenceBackUrlsRequest.builder()
                        .success(successUrl)
                        .failure(failureUrl)
                        .pending(pendingUrl)
                        .build();
                preferenceBuilder.backUrls(backUrls).autoReturn("approved");
            }

            PreferenceClient client = new PreferenceClient();
            Preference preference = client.create(preferenceBuilder.build());

            invoice.setMercadoPagoPreferenceId(preference.getId());
            // En sandbox usar sandbox_init_point para evitar pagos reales
            String paymentUrl = preference.getSandboxInitPoint() != null
                    ? preference.getSandboxInitPoint()
                    : preference.getInitPoint();
            invoice.setPaymentUrl(paymentUrl);

        } catch (com.mercadopago.exceptions.MPApiException e) {
            String detail = "";
            if (e.getApiResponse() != null) {
                detail = " | HTTP " + e.getApiResponse().getStatusCode()
                       + " | " + e.getApiResponse().getContent();
            }
            logger.error("Error MercadoPago API: {}{}", e.getMessage(), detail);
            throw new RuntimeException("Error MercadoPago: " + e.getMessage() + detail);
        } catch (Exception e) {
            logger.error("Error al crear preferencia en MercadoPago: {}", e.getMessage(), e);
            throw new RuntimeException("No se pudo crear el pago en MercadoPago: " + e.getMessage());
        }

        Invoice saved = invoiceRepository.save(invoice);

        // Notificar al reservation-service
        reservationClient.markAsInvoiced(request.getReservationId());

        // Notificar al conductor
        notificationClient.sendNotification(
                "INVOICE_GENERATED",
                request.getDriverId(),
                "DRIVER",
                "Se generó una factura de $" + request.getAmount() + ". Haz clic para pagar.",
                request.getReservationId());

        return mapToDTO(saved);
    }

    @Transactional(readOnly = true)
    public InvoiceDTO getById(Long id) {
        Invoice invoice = invoiceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Factura no encontrada"));
        return mapToDTO(invoice);
    }

    @Transactional(readOnly = true)
    public InvoiceDTO getByReservation(Long reservationId) {
        Invoice invoice = invoiceRepository.findByReservationId(reservationId)
                .orElseThrow(() -> new RuntimeException("Factura no encontrada para esta reserva"));
        return mapToDTO(invoice);
    }

    @Transactional(readOnly = true)
    public List<InvoiceDTO> getByDriver(Long driverId) {
        return invoiceRepository.findByDriverId(driverId).stream()
                .map(this::mapToDTO).toList();
    }

    /** Procesado por el webhook de MercadoPago cuando el pago es aprobado */
    @Transactional
    public void handlePaymentApproved(String mercadoPagoPaymentId, String externalReference) {
        Long reservationId = Long.parseLong(externalReference);
        Invoice invoice = invoiceRepository.findByReservationId(reservationId)
                .orElseThrow(() -> new RuntimeException("Factura no encontrada"));

        invoice.setStatus(InvoiceStatus.PAID);
        invoice.setMercadoPagoPaymentId(mercadoPagoPaymentId);
        invoice.setPaidAt(java.time.LocalDateTime.now());
        invoiceRepository.save(invoice);

        reservationClient.markAsCompleted(reservationId);

        notificationClient.sendNotification(
                "PAYMENT_APPROVED",
                invoice.getDriverId(),
                "DRIVER",
                "Tu pago fue aprobado. ¡Disfruta el parqueadero!",
                reservationId);

        notificationClient.sendNotification(
                "PAYMENT_RECEIVED",
                invoice.getOwnerId(),
                "OWNER",
                "Recibiste un pago de $" + invoice.getAmount() + " por la reserva #" + reservationId,
                reservationId);
    }

    @Transactional
    public void handlePaymentFailed(String externalReference) {
        Long reservationId = Long.parseLong(externalReference);
        invoiceRepository.findByReservationId(reservationId).ifPresent(invoice -> {
            invoice.setStatus(InvoiceStatus.FAILED);
            invoiceRepository.save(invoice);

            notificationClient.sendNotification(
                    "PAYMENT_FAILED",
                    invoice.getDriverId(),
                    "DRIVER",
                    "Tu pago falló. Por favor intenta nuevamente.",
                    reservationId);
        });
    }

    private InvoiceDTO mapToDTO(Invoice i) {
        InvoiceDTO dto = new InvoiceDTO();
        dto.setId(i.getId());
        dto.setReservationId(i.getReservationId());
        dto.setDriverId(i.getDriverId());
        dto.setOwnerId(i.getOwnerId());
        dto.setParkingId(i.getParkingId());
        dto.setAmount(i.getAmount());
        dto.setDescription(i.getDescription());
        dto.setStatus(i.getStatus().toString());
        dto.setPaymentUrl(i.getPaymentUrl());
        dto.setCreatedAt(i.getCreatedAt());
        dto.setPaidAt(i.getPaidAt());
        return dto;
    }
}
