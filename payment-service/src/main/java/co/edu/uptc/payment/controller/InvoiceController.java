package co.edu.uptc.payment.controller;

import co.edu.uptc.payment.dto.CreateInvoiceRequest;
import co.edu.uptc.payment.dto.InvoiceDTO;
import co.edu.uptc.payment.service.InvoiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    /** Propietario genera la factura para una reserva con ambas confirmaciones */
    @PostMapping
    public ResponseEntity<InvoiceDTO> createInvoice(@RequestBody CreateInvoiceRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(invoiceService.createInvoice(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<InvoiceDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(invoiceService.getById(id));
    }

    @GetMapping("/reservation/{reservationId}")
    public ResponseEntity<InvoiceDTO> getByReservation(@PathVariable Long reservationId) {
        return ResponseEntity.ok(invoiceService.getByReservation(reservationId));
    }

    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<InvoiceDTO>> getByDriver(@PathVariable Long driverId) {
        return ResponseEntity.ok(invoiceService.getByDriver(driverId));
    }
}
