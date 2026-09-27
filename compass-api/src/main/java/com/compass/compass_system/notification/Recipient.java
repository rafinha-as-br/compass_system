package com.compass.compass_system.notification;

import com.compass.compass_system.security.JwtUtil;

// Shared by NotificationController and PushTargetController: both resolve
// "who is making this request" from the JWT the same way.
public record Recipient(NotificationRecipientType type, Long id) {
    public static Recipient fromToken(JwtUtil jwtUtil, String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        NotificationRecipientType type = "AGENTE".equals(jwtUtil.getUserTypeFromToken(token))
                ? NotificationRecipientType.AGENT
                : NotificationRecipientType.CLIENT;
        return new Recipient(type, jwtUtil.getUserIdFromToken(token));
    }
}
