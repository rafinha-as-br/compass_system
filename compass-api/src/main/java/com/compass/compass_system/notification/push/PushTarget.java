package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.NotificationRecipientType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;

import java.time.Instant;
import java.util.UUID;

// One device/session's push destination for a recipient — a user can have
// several (one per device). Android carries a UnifiedPush topic; Web
// carries a standard PushSubscription (endpoint + keys). Only the pair
// matching `platform` is ever populated; the other stays null.
@Entity
public class PushTarget {

    @Id
    private String id;

    @Enumerated(EnumType.STRING)
    private NotificationRecipientType recipientType;

    private Long recipientId;

    @Enumerated(EnumType.STRING)
    private PushPlatform platform;

    private String androidTopic;

    @Column(length = 1000)
    private String webEndpoint;
    private String webP256dh;
    private String webAuth;

    private Instant createdAt;

    @PrePersist
    private void prePersist() {
        if (id == null || id.isBlank()) {
            id = UUID.randomUUID().toString();
        }
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public NotificationRecipientType getRecipientType() { return recipientType; }
    public void setRecipientType(NotificationRecipientType recipientType) { this.recipientType = recipientType; }

    public Long getRecipientId() { return recipientId; }
    public void setRecipientId(Long recipientId) { this.recipientId = recipientId; }

    public PushPlatform getPlatform() { return platform; }
    public void setPlatform(PushPlatform platform) { this.platform = platform; }

    public String getAndroidTopic() { return androidTopic; }
    public void setAndroidTopic(String androidTopic) { this.androidTopic = androidTopic; }

    public String getWebEndpoint() { return webEndpoint; }
    public void setWebEndpoint(String webEndpoint) { this.webEndpoint = webEndpoint; }

    public String getWebP256dh() { return webP256dh; }
    public void setWebP256dh(String webP256dh) { this.webP256dh = webP256dh; }

    public String getWebAuth() { return webAuth; }
    public void setWebAuth(String webAuth) { this.webAuth = webAuth; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
