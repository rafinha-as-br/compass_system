package com.compass.compass_system.places;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Cache em memória por termo de busca — a mesma cidade consultada por
 * vários usuários custa uma chamada externa ao Nominatim, não N.
 *
 * ponytail: sem limite de tamanho nem eviction por LRU — cardinalidade de
 * termos de busca (cidades/endereços) é baixa perto da memória disponível.
 * Trocar por Caffeine (maxSize) se isso deixar de ser verdade.
 */
@Component
public class PlaceSuggestionCache {

    private final Duration ttl;
    private final ConcurrentHashMap<String, CacheEntry> entries = new ConcurrentHashMap<>();

    public PlaceSuggestionCache(@Value("${app.nominatim.cache-ttl-hours}") long ttlHours) {
        this.ttl = Duration.ofHours(ttlHours);
    }

    public Optional<List<PlaceSuggestion>> get(String key) {
        CacheEntry entry = entries.get(key);
        if (entry == null || entry.isExpired()) {
            return Optional.empty();
        }
        return Optional.of(entry.suggestions());
    }

    public void put(String key, List<PlaceSuggestion> suggestions) {
        entries.put(key, new CacheEntry(suggestions, Instant.now().plus(ttl)));
    }

    private record CacheEntry(List<PlaceSuggestion> suggestions, Instant expiresAt) {
        boolean isExpired() {
            return Instant.now().isAfter(expiresAt);
        }
    }
}
