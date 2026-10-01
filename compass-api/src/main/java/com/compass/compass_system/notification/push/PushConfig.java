package com.compass.compass_system.notification.push;

import nl.martijndwars.webpush.PushService;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import java.security.GeneralSecurityException;
import java.security.Security;

@Configuration
public class PushConfig {

    static {
        // PushService signs/encrypts VAPID requests via the "BC" provider by
        // name — having bcprov on the classpath isn't enough, it must be
        // registered with the JVM's Security provider list.
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(new BouncyCastleProvider());
        }
    }

    @Bean
    public RestTemplate ntfyRestTemplate(RestTemplateBuilder builder) {
        return builder.build();
    }

    @Bean
    public PushService webPushService(
            @Value("${push.vapid.public-key}") String publicKey,
            @Value("${push.vapid.private-key}") String privateKey,
            @Value("${push.vapid.subject}") String subject) throws GeneralSecurityException {
        return new PushService(publicKey, privateKey, subject);
    }
}
