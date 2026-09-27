package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

// Sends push to Android via UnifiedPush. The distributor the device has
// installed (pointed at our self-hosted ntfy, never ntfy.sh or Firebase)
// mints a one-time endpoint URL on registration and hands it to the app —
// this dispatcher never knows or constructs a topic itself, it just POSTs
// to whichever URL the client registered (same shape as Web Push's
// endpoint). ntfy treats a POST to a topic-specific URL as a "simple"
// publish: the body is the message text, metadata rides in headers.
@Component
public class AndroidPushDispatcher implements PushDispatcher {

    private static final Logger log = LoggerFactory.getLogger(AndroidPushDispatcher.class);

    private final RestTemplate restTemplate;

    public AndroidPushDispatcher(RestTemplate ntfyRestTemplate) {
        this.restTemplate = ntfyRestTemplate;
    }

    @Override
    public PushPlatform platform() {
        return PushPlatform.ANDROID;
    }

    @Override
    public void send(PushTarget target, Notification notification) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Title", "Compass");
            // Placeholder deep link scheme for the RouteCraft side (CPS-148)
            // to register and resolve to the travel's screen.
            headers.set("X-Click", "routecraft://travel/" + notification.getTravelId());

            HttpEntity<String> request = new HttpEntity<>(notification.getMessage(), headers);
            restTemplate.postForEntity(target.getAndroidEndpoint(), request, String.class);
        } catch (Exception e) {
            log.warn("Falha ao enviar push Android via ntfy (targetId={})", target.getId(), e);
        }
    }
}
