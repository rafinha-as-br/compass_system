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

    // The distributor mints this per registration — the dispatcher never
    // knows a topic, it just POSTs to whatever endpoint the client stored.
    private static final String ENDPOINT_URL = "http://ntfy:80/up1a2b3c4d5e";

    private PushTarget androidTarget() {
        PushTarget target = new PushTarget();
        target.setId("pt1");
        target.setRecipientType(NotificationRecipientType.CLIENT);
        target.setRecipientId(1L);
        target.setPlatform(PushPlatform.ANDROID);
        target.setAndroidEndpoint(ENDPOINT_URL);
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
    void postsAJsonBodyDirectlyToTheTargetsOwnEndpoint() {
        // JSON, not headers: onMessage on the RouteCraft side only ever
        // receives the raw POST body — ntfy's X-Title/X-Click headers never
        // cross the UnifiedPush relay, so the deep link's travelId has to
        // ride in the body itself.
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(ENDPOINT_URL))
                .andExpect(method(HttpMethod.POST))
                .andExpect(jsonPath("$.travelId").value("t1"))
                .andExpect(jsonPath("$.message").value("Seu itinerário foi publicado."))
                .andRespond(withSuccess());

        AndroidPushDispatcher dispatcher = new AndroidPushDispatcher(restTemplate);
        dispatcher.send(androidTarget(), sampleNotification());

        server.verify();
    }

    @Test
    void neverThrowsWhenTheEndpointRespondsWithAnError() {
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(ENDPOINT_URL)).andRespond(withServerError());

        AndroidPushDispatcher dispatcher = new AndroidPushDispatcher(restTemplate);

        assertDoesNotThrow(() -> dispatcher.send(androidTarget(), sampleNotification()));
    }
}
