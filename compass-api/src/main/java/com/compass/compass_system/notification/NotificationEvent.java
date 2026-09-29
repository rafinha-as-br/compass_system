package com.compass.compass_system.notification;

// Published in-process right after the originating change commits (see
// NotificationEventRelay); carries exactly what NotificationService.notify
// needs, nothing tied to the HTTP request/entity that triggered it.
public record NotificationEvent(
        NotificationRecipientType recipientType,
        Long recipientId,
        NotificationType type,
        String travelId,
        String message) {
}
