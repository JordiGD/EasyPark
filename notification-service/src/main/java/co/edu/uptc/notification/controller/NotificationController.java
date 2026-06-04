package co.edu.uptc.notification.controller;

import co.edu.uptc.notification.dto.NotificationRequest;
import co.edu.uptc.notification.model.Notification;
import co.edu.uptc.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /** Endpoint interno llamado por otros microservicios para enviar notificaciones */
    @PostMapping("/send")
    public ResponseEntity<Notification> send(@RequestBody NotificationRequest request) {
        return ResponseEntity.ok(notificationService.send(request));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Notification>> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getByUser(userId));
    }

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<List<Notification>> getUnread(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getUnreadByUser(userId));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }
}
