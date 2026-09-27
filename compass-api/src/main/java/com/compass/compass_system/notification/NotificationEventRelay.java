package com.compass.compass_system.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

// Bridges the in-process domain event to the queue, only after the
// originating change has actually committed — publishing before that would
// let a consumer see an event for a change that ends up rolled back.
//
// This relies on the publishing call site running inside a transaction
// (TravelController's upsert methods are @Transactional): with no active
// transaction, @TransactionalEventListener drops the event silently instead
// of firing it — any future NotificationEvent publisher must be
// @Transactional too, or its notifications will simply never arrive.
@Component
public class NotificationEventRelay {

    private static final Logger log = LoggerFactory.getLogger(NotificationEventRelay.class);

    private final RabbitTemplate rabbitTemplate;

    public NotificationEventRelay(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onNotificationEvent(NotificationEvent event) {
        try {
            rabbitTemplate.convertAndSend(RabbitMQConfig.EXCHANGE, RabbitMQConfig.ROUTING_KEY, event);
        } catch (Exception e) {
            // RN (CPS-146): falha ao publicar na fila nunca derruba a operação
            // de negócio — a mudança já foi commitada, só o push desta vez se perde.
            log.error("Falha ao publicar evento de notificação na fila: {}", event, e);
        }
    }
}
