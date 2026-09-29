package com.compass.compass_system.notification;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, String> {
    Page<Notification> findByRecipientTypeAndRecipientId(
            NotificationRecipientType recipientType, Long recipientId, Pageable pageable);

    List<Notification> findByRecipientTypeAndRecipientIdAndReadFalse(
            NotificationRecipientType recipientType, Long recipientId);

    long countByRecipientTypeAndRecipientIdAndReadFalse(
            NotificationRecipientType recipientType, Long recipientId);
}
