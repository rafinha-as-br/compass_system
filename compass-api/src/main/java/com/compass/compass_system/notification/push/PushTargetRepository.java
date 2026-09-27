package com.compass.compass_system.notification.push;

import com.compass.compass_system.notification.NotificationRecipientType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PushTargetRepository extends JpaRepository<PushTarget, String> {
    List<PushTarget> findByRecipientTypeAndRecipientId(NotificationRecipientType recipientType, Long recipientId);

    // Used to make registration idempotent (same device re-registering on
    // every login shouldn't accumulate duplicate rows that all get pushed to).
    Optional<PushTarget> findByRecipientTypeAndRecipientIdAndPlatformAndAndroidEndpoint(
            NotificationRecipientType recipientType, Long recipientId, PushPlatform platform, String androidEndpoint);

    Optional<PushTarget> findByRecipientTypeAndRecipientIdAndPlatformAndWebEndpoint(
            NotificationRecipientType recipientType, Long recipientId, PushPlatform platform, String webEndpoint);
}
