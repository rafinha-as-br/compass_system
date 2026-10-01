package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;
import com.compass.compass_system.notification.NotificationRecipientType;
import com.compass.compass_system.notification.NotificationType;
import nl.martijndwars.webpush.PushService;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.message.BasicHttpResponse;
import org.apache.http.message.BasicStatusLine;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class WebPushDispatcherTest {

    private final PushTargetRepository pushTargetRepository = mock(PushTargetRepository.class);
    private final PushService pushService = mock(PushService.class);
    private final WebPushDispatcher dispatcher = new WebPushDispatcher(pushTargetRepository, pushService);

    private PushTarget webTarget() {
        PushTarget target = new PushTarget();
        target.setId("pt1");
        target.setRecipientType(NotificationRecipientType.CLIENT);
        target.setRecipientId(1L);
        target.setPlatform(PushPlatform.WEB);
        target.setWebEndpoint("https://push.example.com/subscription/abc");
        // Valid-shaped base64url test values — never asserted for content, only that they round-trip.
        target.setWebP256dh("BNcRdreALRFXTkOOUHK1EtK2wtaz5Ry4YfYCA_0QTpQtUbVlUls0VJXg7A8u-Ts1XbjhazAkj7I99e8QcYP7DkM");
        target.setWebAuth("tBHItJI5svbpez7KI4CCXg");
        return target;
    }

    private Notification sampleNotification() {
        Notification notification = new Notification();
        notification.setRecipientType(NotificationRecipientType.CLIENT);
        notification.setRecipientId(1L);
        notification.setType(NotificationType.ITINERARY_PUBLISHED);
        notification.setTravelId("t1");
        notification.setMessage("Seu itinerário foi publicado.");
        return notification;
    }

    // A real (non-mocked) httpcore response — mocking HttpResponse/StatusLine
    // directly hit a Mockito/bytebuddy incompatibility with this JDK, and
    // httpcore already ships a plain, real implementation for exactly this.
    private HttpResponse responseWithStatus(int status) {
        return new BasicHttpResponse(new BasicStatusLine(HttpVersion.HTTP_1_1, status, "status " + status));
    }

    @Test
    void keepsTheTargetOnASuccessfulSend() throws Exception {
        when(pushService.send(any())).thenReturn(responseWithStatus(201));

        dispatcher.send(webTarget(), sampleNotification());

        verify(pushTargetRepository, never()).deleteById(any());
    }

    @Test
    void deletesTheTargetWhenTheSubscriptionIsGone() throws Exception {
        when(pushService.send(any())).thenReturn(responseWithStatus(410));

        PushTarget target = webTarget();
        dispatcher.send(target, sampleNotification());

        verify(pushTargetRepository).deleteById("pt1");
    }

    @Test
    void deletesTheTargetWhenTheSubscriptionIsNotFound() throws Exception {
        when(pushService.send(any())).thenReturn(responseWithStatus(404));

        PushTarget target = webTarget();
        dispatcher.send(target, sampleNotification());

        verify(pushTargetRepository).deleteById("pt1");
    }

    @Test
    void keepsTheTargetOnATransientErrorStatus() throws Exception {
        when(pushService.send(any())).thenReturn(responseWithStatus(503));

        dispatcher.send(webTarget(), sampleNotification());

        verify(pushTargetRepository, never()).deleteById(any());
    }

    @Test
    void neverThrowsWhenThePushServiceItselfFails() throws Exception {
        when(pushService.send(any())).thenThrow(new java.io.IOException("network"));

        assertDoesNotThrow(() -> dispatcher.send(webTarget(), sampleNotification()));
    }
}
