package com.compass.compass_system.notification;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;

import java.time.Instant;
import java.util.UUID;

// Recipient is polymorphic via a discriminator pair (recipientType +
// recipientId) rather than a shared user superclass: ClientUser and
// AgentUser are independent entities with no common base, and retrofitting
// one would touch two already-migrated tables for no gain here.
@Entity
public class Notification {

    @Id
    private String id;

    @Enumerated(EnumType.STRING)
    private NotificationRecipientType recipientType;

    private Long recipientId;

    @Enumerated(EnumType.STRING)
    private NotificationType type;

    private String travelId;

    @Column(length = 500)
    private String message;

    private Instant createdAt;

    private boolean read = false;

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

    public NotificationType getType() { return type; }
    public void setType(NotificationType type) { this.type = type; }

    public String getTravelId() { return travelId; }
    public void setTravelId(String travelId) { this.travelId = travelId; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }
}
