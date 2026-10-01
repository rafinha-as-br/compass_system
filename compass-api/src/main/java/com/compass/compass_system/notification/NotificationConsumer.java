package com.compass.compass_system.notification;

import com.compass.compass_system.notification.push.PushDispatcher;
import com.compass.compass_system.notification.push.PushPlatform;
import com.compass.compass_system.notification.push.PushTarget;
import com.compass.compass_system.notification.push.PushTargetRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

// The other half of NotificationEventRelay: consumes the queued event,
// persists the Notification (the part CPS-145 used to do synchronously in
// TravelController), and pushes it to every device registered for that
// recipient.
@Component
public class NotificationConsumer {

    private static final Logger log = LoggerFactory.getLogger(NotificationConsumer.class);

    private final NotificationService notificationService;
    private final PushTargetRepository pushTargetRepository;
    private final Map<PushPlatform, PushDispatcher> dispatchersByPlatform;

    public NotificationConsumer(
            NotificationService notificationService,
            PushTargetRepository pushTargetRepository,
            List<PushDispatcher> dispatchers) {
        this.notificationService = notificationService;
        this.pushTargetRepository = pushTargetRepository;
        this.dispatchersByPlatform = dispatchers.stream()
                .collect(Collectors.toMap(PushDispatcher::platform, Function.identity()));
    }

    @RabbitListener(queues = RabbitMQConfig.QUEUE)
    public void onMessage(NotificationEvent event) {
        Notification notification = notificationService.notify(
                event.recipientType(), event.recipientId(), event.type(), event.travelId(), event.message());

        if (notification == null) {
            return; // recipient never resolved — nothing was persisted, nothing to push
        }

        dispatchPush(notification);
    }

    private void dispatchPush(Notification notification) {
        List<PushTarget> targets = pushTargetRepository.findByRecipientTypeAndRecipientId(
                notification.getRecipientType(), notification.getRecipientId());

        for (PushTarget target : targets) {
            PushDispatcher dispatcher = dispatchersByPlatform.get(target.getPlatform());
            if (dispatcher == null) {
                continue;
            }
            try {
                dispatcher.send(target, notification);
            } catch (Exception e) {
                // RN (CPS-146): falha no envio de push é best-effort — nunca
                // derruba o processamento do evento nem os demais destinos.
                log.warn("Falha ao despachar push (targetId={}, platform={})", target.getId(), target.getPlatform(), e);
            }
        }
    }
}
