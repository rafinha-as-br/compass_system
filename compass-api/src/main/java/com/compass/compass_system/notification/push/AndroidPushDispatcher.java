package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

// Sends push to Android via UnifiedPush, relayed through a self-hosted ntfy
// instance (never ntfy.sh, never Firebase) — see ntfy's JSON publish API.
@Component
public class AndroidPushDispatcher implements PushDispatcher {

    private static final Logger log = LoggerFactory.getLogger(AndroidPushDispatcher.class);

    private final RestTemplate restTemplate;
    private final String ntfyBaseUrl;

    public AndroidPushDispatcher(RestTemplate ntfyRestTemplate, @Value("${push.ntfy.base-url}") String ntfyBaseUrl) {
        this.restTemplate = ntfyRestTemplate;
        this.ntfyBaseUrl = ntfyBaseUrl;
    }

    @Override
    public PushPlatform platform() {
        return PushPlatform.ANDROID;
    }

    @Override
    public void send(PushTarget target, Notification notification) {
        try {
            Map<String, Object> body = Map.of(
                    "topic", target.getAndroidTopic(),
                    "title", "Compass",
                    "message", notification.getMessage(),
                    // Placeholder deep link scheme for the RouteCraft side (CPS-148)
                    // to register and resolve to the travel's screen.
                    "click", "routecraft://travel/" + notification.getTravelId());

            restTemplate.postForEntity(ntfyBaseUrl, body, String.class);
        } catch (Exception e) {
            log.warn("Falha ao enviar push Android via ntfy (topic={})", target.getAndroidTopic(), e);
        }
    }
}
