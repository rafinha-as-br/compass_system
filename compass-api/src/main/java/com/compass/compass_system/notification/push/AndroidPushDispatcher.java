package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

// Sends push to Android via UnifiedPush. The distributor the device has
// installed (pointed at our self-hosted ntfy, never ntfy.sh or Firebase)
// mints a one-time endpoint URL on registration and hands it to the app —
// this dispatcher never knows or constructs a topic itself, it just POSTs
// to whichever URL the client registered (same shape as Web Push's
// endpoint).
//
// The body is JSON, not plain text: UnifiedPush's `onMessage` on the
// RouteCraft side only ever gets the raw bytes of what was POSTed here —
// HTTP headers (ntfy's own X-Title/X-Click convention, meant for ntfy's
// native UI) never cross that relay. Since ntfy here is an invisible
// transport (RouteCraft renders its own local notification), the JSON body
// is exactly what needs to survive the trip — same payload shape as
// WebPushDispatcher, for the two clients to parse identically.
@Component
public class AndroidPushDispatcher implements PushDispatcher {

    private static final Logger log = LoggerFactory.getLogger(AndroidPushDispatcher.class);

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();

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
            String payload = objectMapper.writeValueAsString(Map.of(
                    "travelId", notification.getTravelId(),
                    "message", notification.getMessage()));
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            restTemplate.postForEntity(target.getAndroidEndpoint(), new HttpEntity<>(payload, headers), String.class);
        } catch (Exception e) {
            log.warn("Falha ao enviar push Android via ntfy (targetId={})", target.getId(), e);
        }
    }
}
