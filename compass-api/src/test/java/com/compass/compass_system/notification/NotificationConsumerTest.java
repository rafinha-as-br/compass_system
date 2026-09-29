package com.compass.compass_system.notification;

import com.compass.compass_system.notification.push.PushDispatcher;
import com.compass.compass_system.notification.push.PushPlatform;
import com.compass.compass_system.notification.push.PushTarget;
import com.compass.compass_system.notification.push.PushTargetRepository;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class NotificationConsumerTest {

    private final NotificationService notificationService = mock(NotificationService.class);
    private final PushTargetRepository pushTargetRepository = mock(PushTargetRepository.class);

    private NotificationEvent sampleEvent() {
        return new NotificationEvent(
                NotificationRecipientType.CLIENT, 1L, NotificationType.ITINERARY_PUBLISHED, "t1", "msg");
    }

    private Notification savedNotification() {
        Notification notification = new Notification();
        notification.setId("n1");
        notification.setRecipientType(NotificationRecipientType.CLIENT);
        notification.setRecipientId(1L);
        notification.setType(NotificationType.ITINERARY_PUBLISHED);
        notification.setTravelId("t1");
        notification.setMessage("msg");
        return notification;
    }

    private PushTarget targetFor(PushPlatform platform) {
        PushTarget target = new PushTarget();
        target.setId("pt1");
        target.setRecipientType(NotificationRecipientType.CLIENT);
        target.setRecipientId(1L);
        target.setPlatform(platform);
        return target;
    }

    @Test
    void persistsTheNotificationAndDispatchesToEveryMatchingTarget() {
        Notification notification = savedNotification();
        when(notificationService.notify(any(), any(), any(), any(), any())).thenReturn(notification);

        PushTarget target = targetFor(PushPlatform.ANDROID);
        when(pushTargetRepository.findByRecipientTypeAndRecipientId(NotificationRecipientType.CLIENT, 1L))
                .thenReturn(List.of(target));

        PushDispatcher androidDispatcher = mock(PushDispatcher.class);
        when(androidDispatcher.platform()).thenReturn(PushPlatform.ANDROID);

        NotificationConsumer consumer =
                new NotificationConsumer(notificationService, pushTargetRepository, List.of(androidDispatcher));

        consumer.onMessage(sampleEvent());

        verify(androidDispatcher).send(target, notification);
    }

    @Test
    void skipsDispatchWhenTheRecipientCouldNotBeResolved() {
        when(notificationService.notify(any(), any(), any(), any(), any())).thenReturn(null);

        NotificationConsumer consumer =
                new NotificationConsumer(notificationService, pushTargetRepository, List.of());

        consumer.onMessage(sampleEvent());

        verifyNoInteractions(pushTargetRepository);
    }

    @Test
    void oneDispatcherThrowingDoesNotStopTheOthersOrPropagate() {
        Notification notification = savedNotification();
        when(notificationService.notify(any(), any(), any(), any(), any())).thenReturn(notification);

        PushTarget androidTarget = targetFor(PushPlatform.ANDROID);
        androidTarget.setId("pt-android");
        PushTarget webTarget = targetFor(PushPlatform.WEB);
        webTarget.setId("pt-web");
        when(pushTargetRepository.findByRecipientTypeAndRecipientId(NotificationRecipientType.CLIENT, 1L))
                .thenReturn(List.of(androidTarget, webTarget));

        PushDispatcher androidDispatcher = mock(PushDispatcher.class);
        when(androidDispatcher.platform()).thenReturn(PushPlatform.ANDROID);
        doThrow(new RuntimeException("ntfy indisponível")).when(androidDispatcher).send(any(), any());

        PushDispatcher webDispatcher = mock(PushDispatcher.class);
        when(webDispatcher.platform()).thenReturn(PushPlatform.WEB);

        NotificationConsumer consumer = new NotificationConsumer(
                notificationService, pushTargetRepository, List.of(androidDispatcher, webDispatcher));

        assertDoesNotThrow(() -> consumer.onMessage(sampleEvent()));

        verify(webDispatcher).send(eq(webTarget), eq(notification));
    }

    @Test
    void ignoresATargetWhoseNoPlatformDispatcherIsRegistered() {
        Notification notification = savedNotification();
        when(notificationService.notify(any(), any(), any(), any(), any())).thenReturn(notification);

        PushTarget webTarget = targetFor(PushPlatform.WEB);
        when(pushTargetRepository.findByRecipientTypeAndRecipientId(NotificationRecipientType.CLIENT, 1L))
                .thenReturn(List.of(webTarget));

        // Only an Android dispatcher registered — no bean exists for WEB.
        PushDispatcher androidDispatcher = mock(PushDispatcher.class);
        when(androidDispatcher.platform()).thenReturn(PushPlatform.ANDROID);

        NotificationConsumer consumer =
                new NotificationConsumer(notificationService, pushTargetRepository, List.of(androidDispatcher));

        assertDoesNotThrow(() -> consumer.onMessage(sampleEvent()));
        verify(androidDispatcher, never()).send(any(), any());
    }
}
