package com.compass.compass_system.notification.push;

// Only the fields matching `platform` are expected to be non-null — the
// controller validates that pairing before persisting.
public record PushTargetRegistrationRequest(
        PushPlatform platform,
        String androidTopic,
        String webEndpoint,
        String webP256dh,
        String webAuth) {
}
