package com.compass.compass_system.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

/**
 * Classe utilitária para gerar e validar tokens JWT.
 * O JWT é o padrão da indústria para autenticação stateless em APIs REST.
 */
@Component
public class JwtUtil {

    private final SecretKey key;
    private final long expirationMs;

    public JwtUtil(
            @Value("${jwt.secret:compass-system-secret-key-que-deve-ter-pelo-menos-256-bits-ok}") String secret,
            @Value("${jwt.expiration-ms:86400000}") long expirationMs) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs;
    }

    /**
     * Gera um token JWT com o email do usuário e o tipo (cliente/agente).
     */
    public String generateToken(String email, String userType, Long userId) {
        return Jwts.builder()
                .subject(email)
                .claim("userType", userType)
                .claim("userId", userId)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expirationMs))
                .signWith(key)
                .compact();
    }

    /**
     * Extrai o email (subject) do token.
     */
    public String getEmailFromToken(String token) {
        return getClaims(token).getSubject();
    }

    /**
     * Extrai o tipo de usuário do token.
     */
    public String getUserTypeFromToken(String token) {
        return getClaims(token).get("userType", String.class);
    }

    /**
     * Extrai o ID do usuário do token.
     */
    public Long getUserIdFromToken(String token) {
        return getClaims(token).get("userId", Long.class);
    }

    /**
     * Extrai o instante de emissão (claim "iat") do token.
     */
    public Instant getIssuedAtFromToken(String token) {
        return getClaims(token).getIssuedAt().toInstant();
    }

    /**
     * Valida se o token é válido e não expirou.
     */
    public boolean isTokenValid(String token) {
        try {
            getClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
