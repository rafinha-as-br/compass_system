package com.compass.compass_system.notification.push;

import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.exceptions.ResourceNotFoundException;
import com.compass.compass_system.notification.Recipient;
import com.compass.compass_system.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

// Registration is called by the app at login, removal at logout (both
// RouteCraft/CPS-148 and Travel Matrix/CPS-149) — this issue only builds the
// backend side of that contract.
@RestController
@RequestMapping("/push-targets")
@CrossOrigin(origins = "*")
public class PushTargetController {

    @Autowired
    private PushTargetRepository pushTargetRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${push.vapid.public-key}")
    private String vapidPublicKey;

    // ─── GET /push-targets/vapid-public-key ────────────────────────────────────
    // The Web client needs this to build its PushSubscription
    // (PushManager.subscribe({ applicationServerKey: ... })) before it has
    // anything to register.
    @GetMapping("/vapid-public-key")
    public ResponseEntity<Map<String, String>> vapidPublicKey() {
        return ResponseEntity.ok(Map.of("publicKey", vapidPublicKey));
    }

    @PostMapping
    public ResponseEntity<PushTarget> register(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody PushTargetRegistrationRequest request) {

        validate(request);

        Recipient recipient = Recipient.fromToken(jwtUtil, authHeader);

        // Idempotent: the same device re-registering on every login (a
        // realistic pattern for an app that doesn't track whether it already
        // registered) reuses its existing row instead of accumulating
        // duplicates that would each receive the same push.
        PushTarget target = findExisting(recipient, request).orElseGet(PushTarget::new);
        target.setRecipientType(recipient.type());
        target.setRecipientId(recipient.id());
        target.setPlatform(request.platform());
        target.setAndroidEndpoint(request.androidEndpoint());
        target.setWebEndpoint(request.webEndpoint());
        target.setWebP256dh(request.webP256dh());
        target.setWebAuth(request.webAuth());

        return ResponseEntity.ok(pushTargetRepository.save(target));
    }

    private java.util.Optional<PushTarget> findExisting(Recipient recipient, PushTargetRegistrationRequest request) {
        return switch (request.platform()) {
            case ANDROID -> pushTargetRepository.findByRecipientTypeAndRecipientIdAndPlatformAndAndroidEndpoint(
                    recipient.type(), recipient.id(), PushPlatform.ANDROID, request.androidEndpoint());
            case WEB -> pushTargetRepository.findByRecipientTypeAndRecipientIdAndPlatformAndWebEndpoint(
                    recipient.type(), recipient.id(), PushPlatform.WEB, request.webEndpoint());
        };
    }

    // ─── DELETE /push-targets/{id} ──────────────────────────────────────────────
    // 404s (rather than 403) when the target belongs to someone else, so
    // ownership isn't leaked — same convention as NotificationController.
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> unregister(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable String id) {

        Recipient recipient = Recipient.fromToken(jwtUtil, authHeader);
        PushTarget target = pushTargetRepository.findById(id)
                .filter(t -> t.getRecipientType() == recipient.type() && t.getRecipientId().equals(recipient.id()))
                .orElseThrow(() -> new ResourceNotFoundException("Destino de push não encontrado: " + id));

        pushTargetRepository.delete(target);
        return ResponseEntity.noContent().build();
    }

    private void validate(PushTargetRegistrationRequest request) {
        if (request.platform() == null) {
            throw new BusinessException("platform é obrigatório.");
        }
        boolean valid = switch (request.platform()) {
            case ANDROID -> request.androidEndpoint() != null && !request.androidEndpoint().isBlank();
            case WEB -> request.webEndpoint() != null && request.webP256dh() != null && request.webAuth() != null;
        };
        if (!valid) {
            throw new BusinessException("Campos obrigatórios ausentes para a plataforma " + request.platform() + ".");
        }
    }
}
