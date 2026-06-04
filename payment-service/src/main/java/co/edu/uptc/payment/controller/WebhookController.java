package co.edu.uptc.payment.controller;

import co.edu.uptc.payment.service.InvoiceService;
import com.mercadopago.client.payment.PaymentClient;
import com.mercadopago.resources.payment.Payment;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class WebhookController {

    private static final Logger logger = LoggerFactory.getLogger(WebhookController.class);

    private final InvoiceService invoiceService;

    /**
     * Webhook de MercadoPago.
     * MercadoPago envía notificaciones con tipo "payment" y el ID del pago.
     * Se consulta el pago para obtener el external_reference (reservationId).
     */
    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "data.id", required = false) String dataId,
            @RequestBody(required = false) Map<String, Object> body) {

        try {
            String paymentId = dataId;

            // Algunos webhooks envían el ID en el body
            if (paymentId == null && body != null) {
                Object data = body.get("data");
                if (data instanceof Map<?, ?> dataMap) {
                    Object id = dataMap.get("id");
                    if (id != null) paymentId = id.toString();
                }
            }

            if (paymentId == null || !"payment".equals(type)) {
                return ResponseEntity.ok().build();
            }

            PaymentClient paymentClient = new PaymentClient();
            Payment payment = paymentClient.get(Long.parseLong(paymentId));

            String status = payment.getStatus();
            String externalRef = payment.getExternalReference();

            logger.info("Webhook MercadoPago: paymentId={} status={} ref={}", paymentId, status, externalRef);

            if (externalRef == null) return ResponseEntity.ok().build();

            switch (status) {
                case "approved" -> invoiceService.handlePaymentApproved(paymentId, externalRef);
                case "rejected", "cancelled" -> invoiceService.handlePaymentFailed(externalRef);
                default -> logger.info("Estado de pago ignorado: {}", status);
            }
        } catch (Exception e) {
            logger.error("Error procesando webhook: {}", e.getMessage(), e);
        }

        return ResponseEntity.ok().build();
    }
}
