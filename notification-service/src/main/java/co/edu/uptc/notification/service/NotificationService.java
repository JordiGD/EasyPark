package co.edu.uptc.notification.service;

import co.edu.uptc.notification.dto.NotificationRequest;
import co.edu.uptc.notification.model.Notification;
import co.edu.uptc.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository repository;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public Notification send(NotificationRequest request) {
        Notification notification = new Notification();
        notification.setTargetUserId(request.getTargetUserId());
        notification.setRole(request.getRole());
        notification.setType(request.getType());
        notification.setMessage(request.getMessage());
        notification.setReservationId(request.getReservationId());

        Notification saved = repository.save(notification);

        // Broadcast via WebSocket al topic del usuario
        String topic = "/topic/users/" + request.getTargetUserId();
        messagingTemplate.convertAndSend(topic, saved);

        // También broadcast al topic de la reserva
        if (request.getReservationId() != null) {
            messagingTemplate.convertAndSend("/topic/reservations/" + request.getReservationId(), saved);
        }

        return saved;
    }

    @Transactional(readOnly = true)
    public List<Notification> getByUser(Long userId) {
        return repository.findByTargetUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public List<Notification> getUnreadByUser(Long userId) {
        return repository.findByTargetUserIdAndReadFalseOrderByCreatedAtDesc(userId);
    }

    @Transactional
    public void markAsRead(Long notificationId) {
        repository.findById(notificationId).ifPresent(n -> {
            n.setRead(true);
            repository.save(n);
        });
    }
}
