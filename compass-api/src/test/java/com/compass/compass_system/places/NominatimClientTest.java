package com.compass.compass_system.places;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.net.http.HttpRequest;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class NominatimClientTest {

    private final NominatimClient client = new NominatimClient(
            "https://nominatim.openstreetmap.org/search",
            "CompassSystem/1.0 (+https://github.com/rafinha-as-br/compass_system)",
            new ObjectMapper());

    @Test
    void shouldUseShortNameFieldAsSuggestionName() {
        String json = """
                [
                  {"name": "Florianópolis", "display_name": "Florianópolis, Santa Catarina, Região Sul, Brasil", "lat": "-27.5954", "lon": "-48.5480"},
                  {"name": "Aeroporto Internacional de Navegantes", "display_name": "Aeroporto Internacional de Navegantes, Rua X, Centro, Navegantes, Brasil", "lat": "-26.8800", "lon": "-48.6500"}
                ]
                """;

        List<PlaceSuggestion> result = client.parse(json);

        assertThat(result).containsExactly(
                new PlaceSuggestion("Florianópolis", -27.5954, -48.5480),
                new PlaceSuggestion("Aeroporto Internacional de Navegantes", -26.8800, -48.6500)
        );
    }

    @Test
    void shouldFallBackToFirstDisplayNameSegmentWhenNameIsMissingOrBlank() {
        String json = """
                [
                  {"display_name": "Floriano, PI, Brasil", "lat": "-6.7671", "lon": "-43.0225"},
                  {"name": "  ", "display_name": "Blumenau, Santa Catarina, Brasil", "lat": "-26.9194", "lon": "-49.0661"}
                ]
                """;

        List<PlaceSuggestion> result = client.parse(json);

        assertThat(result).containsExactly(
                new PlaceSuggestion("Floriano", -6.7671, -43.0225),
                new PlaceSuggestion("Blumenau", -26.9194, -49.0661)
        );
    }

    @Test
    void shouldReturnEmptyListWhenProviderHasNoMatches() {
        assertThat(client.parse("[]")).isEmpty();
    }

    @Test
    void shouldTreatMalformedResponseAsProviderUnavailable() {
        assertThatThrownBy(() -> client.parse("not json"))
                .isInstanceOf(PlaceProviderUnavailableException.class);
    }

    @Test
    void shouldTreatNonNumericCoordinatesAsProviderUnavailableInsteadOfAnOpaque500() {
        String json = """
                [{"display_name": "Lugar sem coordenada válida", "lat": "abc", "lon": "-48.5480"}]
                """;

        assertThatThrownBy(() -> client.parse(json))
                .isInstanceOf(PlaceProviderUnavailableException.class);
    }

    @Test
    void shouldSendIdentifiableUserAgentAsThePolicyRequires() {
        HttpRequest request = client.buildRequest("Floripa");

        assertThat(request.headers().firstValue("User-Agent"))
                .contains("CompassSystem/1.0 (+https://github.com/rafinha-as-br/compass_system)");
        assertThat(request.uri().toString()).contains("q=Floripa").contains("format=json");
    }
}
