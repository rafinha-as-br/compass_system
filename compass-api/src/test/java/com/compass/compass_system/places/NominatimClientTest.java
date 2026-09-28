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
    void shouldParseNominatimResponseIntoOwnContract() {
        String json = """
                [
                  {"display_name": "Florianópolis, SC, Brasil", "lat": "-27.5954", "lon": "-48.5480"},
                  {"display_name": "Floriano, PI, Brasil", "lat": "-6.7671", "lon": "-43.0225"}
                ]
                """;

        List<PlaceSuggestion> result = client.parse(json);

        assertThat(result).containsExactly(
                new PlaceSuggestion("Florianópolis, SC, Brasil", -27.5954, -48.5480),
                new PlaceSuggestion("Floriano, PI, Brasil", -6.7671, -43.0225)
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
