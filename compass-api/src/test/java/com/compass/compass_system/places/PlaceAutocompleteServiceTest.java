package com.compass.compass_system.places;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class PlaceAutocompleteServiceTest {

    private final PlaceProvider provider = mock(PlaceProvider.class);
    private final PlaceSuggestionCache cache = new PlaceSuggestionCache(24);
    // Espaçamento em 0: este teste cobre cache/falha, não o controle de taxa
    // em si (ver NominatimRateLimiterTest) — evita ~1s de sleep real por caso.
    private final NominatimRateLimiter rateLimiter = new NominatimRateLimiter(0);
    private final PlaceAutocompleteService service = new PlaceAutocompleteService(provider, cache, rateLimiter);

    @Test
    void shouldReturnEmptyListWithoutCallingProviderWhenQueryIsTooShort() {
        assertThat(service.autocomplete("f")).isEmpty();
        assertThat(service.autocomplete("  ")).isEmpty();
        assertThat(service.autocomplete(null)).isEmpty();

        verify(provider, times(0)).search(org.mockito.ArgumentMatchers.anyString());
    }

    @Test
    void shouldCallProviderOnceAndCacheResult() {
        List<PlaceSuggestion> results = List.of(new PlaceSuggestion("Florianópolis, SC, Brasil", -27.59, -48.55));
        when(provider.search("Floripa")).thenReturn(results);

        List<PlaceSuggestion> first = service.autocomplete("Floripa");
        List<PlaceSuggestion> second = service.autocomplete(" floripa ");

        assertThat(first).isEqualTo(results);
        assertThat(second).isEqualTo(results);
        verify(provider, times(1)).search("Floripa");
    }

    @Test
    void shouldPropagateProviderFailureWithoutCachingIt() {
        when(provider.search("indisponivel"))
                .thenThrow(new PlaceProviderUnavailableException("fora do ar"))
                .thenReturn(List.of(new PlaceSuggestion("Recuperado", 0, 0)));

        assertThatThrownBy(() -> service.autocomplete("indisponivel"))
                .isInstanceOf(PlaceProviderUnavailableException.class);

        // Falha não fica em cache — a próxima tentativa chama o provedor de novo.
        List<PlaceSuggestion> retry = service.autocomplete("indisponivel");
        assertThat(retry).hasSize(1);
        verify(provider, times(2)).search("indisponivel");
    }
}
