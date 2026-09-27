package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;
import com.compass.compass_system.notification.NotificationRecipientType;
import com.compass.compass_system.notification.NotificationType;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.jsonPath;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class AndroidPushDispatcherTest {

    private static final String NTFY_URL = "http://ntfy:80/";

    private PushTarget androidTarget() {
        PushTarget target = new PushTarget();
        target.setId("pt1");
        target.setRecipientType(NotificationRecipientType.CLIENT);
        target.setRecipientId(1L);
        target.setPlatform(PushPlatform.ANDROID);
        target.setAndroidTopic("compass-client-1");
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

    @Test
    void postsTheNotificationToNtfyAsJsonWithTheDeepLinkPayload() {
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(NTFY_URL))
                .andExpect(method(HttpMethod.POST))
                .andExpect(jsonPath("$.topic").value("compass-client-1"))
                .andExpect(jsonPath("$.message").value("Seu itinerário foi publicado."))
                .andExpect(jsonPath("$.click").value("routecraft://travel/t1"))
                .andRespond(withSuccess());

        AndroidPushDispatcher dispatcher = new AndroidPushDispatcher(restTemplate, NTFY_URL);
        dispatcher.send(androidTarget(), sampleNotification());

        server.verify();
    }

    @Test
    void neverThrowsWhenNtfyRespondsWithAnError() {
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(NTFY_URL)).andRespond(withServerError());

        AndroidPushDispatcher dispatcher = new AndroidPushDispatcher(restTemplate, NTFY_URL);

        assertDoesNotThrow(() -> dispatcher.send(androidTarget(), sampleNotification()));
    }
}
