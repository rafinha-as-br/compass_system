package com.compass.compass_system.notification;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    // A missing recipientId (a travel created before Travel.clientId/agentId
    // existed) isn't an error — there's simply nowhere to deliver it, so
    // this skips silently rather than failing the caller. Returns the saved
    // Notification (or null when skipped) so NotificationConsumer knows
    // whether there's anything left to push.
    public Notification notify(NotificationRecipientType recipientType, Long recipientId,
                                NotificationType type, String travelId, String message) {
        if (recipientId == null) {
            return null;
        }

        Notification notification = new Notification();
        notification.setRecipientType(recipientType);
        notification.setRecipientId(recipientId);
        notification.setType(type);
        notification.setTravelId(travelId);
        notification.setMessage(message);
        return notificationRepository.save(notification);
    }
}
