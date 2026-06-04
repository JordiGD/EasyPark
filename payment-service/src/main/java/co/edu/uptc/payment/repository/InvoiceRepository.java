package co.edu.uptc.payment.repository;

import co.edu.uptc.payment.model.Invoice;
import co.edu.uptc.payment.model.InvoiceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {
    Optional<Invoice> findByReservationId(Long reservationId);
    List<Invoice> findByDriverId(Long driverId);
    Optional<Invoice> findByMercadoPagoPreferenceId(String preferenceId);
    Optional<Invoice> findByMercadoPagoPaymentId(String paymentId);
    List<Invoice> findByDriverIdAndStatus(Long driverId, InvoiceStatus status);
}
