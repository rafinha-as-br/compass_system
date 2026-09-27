package com.compass.compass_system.notification;

import com.compass.compass_system.exceptions.ResourceNotFoundException;
import com.compass.compass_system.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // ─── GET /notifications ─────────────────────────────────────────────────────
    // Lists the authenticated user's own notifications, paginated, newest first.
    @GetMapping
    public ResponseEntity<Page<Notification>> listNotifications(
            @RequestHeader("Authorization") String authHeader,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {

        Recipient recipient = Recipient.fromToken(jwtUtil, authHeader);
        return ResponseEntity.ok(notificationRepository.findByRecipientTypeAndRecipientId(
                recipient.type(), recipient.id(), pageable));
    }

    // ─── GET /notifications/unread-count ────────────────────────────────────────
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> unreadCount(@RequestHeader("Authorization") String authHeader) {
        Recipient recipient = Recipient.fromToken(jwtUtil, authHeader);
        long count = notificationRepository.countByRecipientTypeAndRecipientIdAndReadFalse(
                recipient.type(), recipient.id());
        return ResponseEntity.ok(Map.of("count", count));
    }

    // ─── PUT /notifications/{id}/read ───────────────────────────────────────────
    // Marks a single notification as read. 404s (rather than 403) when the
    // notification belongs to someone else, so ownership isn't leaked.
    @PutMapping("/{id}/read")
    public ResponseEntity<Notification> markAsRead(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable String id) {

        Recipient recipient = Recipient.fromToken(jwtUtil, authHeader);
        Notification notification = notificationRepository.findById(id)
                .filter(n -> n.getRecipientType() == recipient.type() && n.getRecipientId().equals(recipient.id()))
                .orElseThrow(() -> new ResourceNotFoundException("Notificação não encontrada: " + id));

        notification.setRead(true);
        return ResponseEntity.ok(notificationRepository.save(notification));
    }

    // ─── PUT /notifications/read-all ────────────────────────────────────────────
    @PutMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(@RequestHeader("Authorization") String authHeader) {
        Recipient recipient = Recipient.fromToken(jwtUtil, authHeader);
        List<Notification> unread = notificationRepository.findByRecipientTypeAndRecipientIdAndReadFalse(
                recipient.type(), recipient.id());
        unread.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(unread);
        return ResponseEntity.noContent().build();
    }
}
