package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import nl.martijndwars.webpush.PushService;
import org.apache.http.HttpResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

// Sends push to the browser via standard Web Push (VAPID) — no vendor SDK,
// works the same for any browser that implements the Push API.
@Component
public class WebPushDispatcher implements PushDispatcher {

    private static final Logger log = LoggerFactory.getLogger(WebPushDispatcher.class);

    // The push service itself returns these for a subscription the browser
    // has revoked or that expired — reusing it forever would just accumulate
    // dead rows and failed sends, so it's deleted the first time this shows up.
    private static final int STATUS_NOT_FOUND = 404;
    private static final int STATUS_GONE = 410;

    private final PushTargetRepository pushTargetRepository;
    private final PushService pushService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public WebPushDispatcher(PushTargetRepository pushTargetRepository, PushService pushService) {
        this.pushTargetRepository = pushTargetRepository;
        this.pushService = pushService;
    }

    @Override
    public PushPlatform platform() {
        return PushPlatform.WEB;
    }

    @Override
    public void send(PushTarget target, Notification notification) {
        try {
            nl.martijndwars.webpush.Notification pushNotification = nl.martijndwars.webpush.Notification.builder()
                    .endpoint(target.getWebEndpoint())
                    .userPublicKey(target.getWebP256dh())
                    .userAuth(target.getWebAuth())
                    .payload(payloadFor(notification))
                    .build();

            HttpResponse response = pushService.send(pushNotification);
            int status = response.getStatusLine().getStatusCode();
            if (status == STATUS_NOT_FOUND || status == STATUS_GONE) {
                pushTargetRepository.deleteById(target.getId());
            }
        } catch (Exception e) {
            log.warn("Falha ao enviar Web Push (targetId={})", target.getId(), e);
        }
    }

    private String payloadFor(Notification notification) throws JsonProcessingException {
        return objectMapper.writeValueAsString(Map.of(
                "travelId", notification.getTravelId(),
                "message", notification.getMessage()));
    }
}
