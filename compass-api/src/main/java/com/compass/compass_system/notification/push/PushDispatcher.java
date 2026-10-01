package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.Notification;

// One implementation per platform (Android via UnifiedPush/ntfy, Web via
// VAPID) — NotificationConsumer picks the one matching each target's platform.
public interface PushDispatcher {
    PushPlatform platform();

    // Never throws for a delivery failure — the caller treats push as
    // best-effort and does not want a bad target to stop the others.
    void send(PushTarget target, Notification notification);
}
