package com.compass.compass_system.places;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

/**
 * Orquestra a busca de lugares: cache primeiro, depois controle de taxa,
 * só então a chamada real ao provedor.
 */
@Service
public class PlaceAutocompleteService {

    private static final int MIN_QUERY_LENGTH = 2;

    private final PlaceProvider provider;
    private final PlaceSuggestionCache cache;
    private final NominatimRateLimiter rateLimiter;

    public PlaceAutocompleteService(PlaceProvider provider, PlaceSuggestionCache cache, NominatimRateLimiter rateLimiter) {
        this.provider = provider;
        this.cache = cache;
        this.rateLimiter = rateLimiter;
    }

    public List<PlaceSuggestion> autocomplete(String query) {
        if (query == null || query.trim().length() < MIN_QUERY_LENGTH) {
            return List.of();
        }

        String trimmedQuery = query.trim();
        String cacheKey = trimmedQuery.toLowerCase(Locale.ROOT);

        return cache.get(cacheKey).orElseGet(() -> {
            rateLimiter.awaitTurn();
            List<PlaceSuggestion> results = provider.search(trimmedQuery);
            cache.put(cacheKey, results);
            return results;
        });
    }
}
