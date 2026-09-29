package com.compass.compass_system.notification;

import org.junit.jupiter.api.Test;
import org.springframework.amqp.rabbit.core.RabbitTemplate;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class NotificationEventRelayTest {

    private final RabbitTemplate rabbitTemplate = mock(RabbitTemplate.class);
    private final NotificationEventRelay relay = new NotificationEventRelay(rabbitTemplate);

    private NotificationEvent sampleEvent() {
        return new NotificationEvent(
                NotificationRecipientType.CLIENT, 1L, NotificationType.ITINERARY_PUBLISHED, "t1", "msg");
    }

    @Test
    void publishesTheEventToTheConfiguredExchangeAndRoutingKey() {
        NotificationEvent event = sampleEvent();

        relay.onNotificationEvent(event);

        verify(rabbitTemplate).convertAndSend(RabbitMQConfig.EXCHANGE, RabbitMQConfig.ROUTING_KEY, event);
    }

    @Test
    void neverPropagatesAFailureToPublish() {
        doThrow(new RuntimeException("RabbitMQ indisponível"))
                .when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(Object.class));

        assertDoesNotThrow(() -> relay.onNotificationEvent(sampleEvent()));
    }
}
