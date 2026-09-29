package com.compass.compass_system.places;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;

/**
 * Cliente HTTP para o Nominatim público. Único ponto do sistema que fala
 * com o provedor externo — os apps nunca chamam o Nominatim diretamente.
 */
@Component
public class NominatimClient implements PlaceProvider {

    private static final Duration TIMEOUT = Duration.ofSeconds(5);

    private final String baseUrl;
    private final String userAgent;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient = HttpClient.newBuilder().connectTimeout(TIMEOUT).build();

    public NominatimClient(
            @Value("${app.nominatim.base-url}") String baseUrl,
            @Value("${app.nominatim.user-agent}") String userAgent,
            ObjectMapper objectMapper) {
        this.baseUrl = baseUrl;
        this.userAgent = userAgent;
        this.objectMapper = objectMapper;
    }

    @Override
    public List<PlaceSuggestion> search(String query) {
        try {
            HttpResponse<String> response = httpClient.send(buildRequest(query), HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                throw new PlaceProviderUnavailableException(
                        "Nominatim respondeu com status " + response.statusCode());
            }
            return parse(response.body());
        } catch (IOException e) {
            throw new PlaceProviderUnavailableException("Não foi possível consultar o serviço de geocodificação.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new PlaceProviderUnavailableException("Consulta ao serviço de geocodificação interrompida.");
        }
    }

    HttpRequest buildRequest(String query) {
        String encodedQuery = URLEncoder.encode(query, StandardCharsets.UTF_8);
        URI uri = URI.create(baseUrl + "?q=" + encodedQuery + "&format=json&limit=5&addressdetails=0");
        return HttpRequest.newBuilder(uri)
                // Exigência explícita da política de uso do Nominatim público: um
                // User-Agent identificável, não o default de biblioteca HTTP.
                .header("User-Agent", userAgent)
                .timeout(TIMEOUT)
                .GET()
                .build();
    }

    List<PlaceSuggestion> parse(String json) {
        try {
            List<NominatimResult> results = objectMapper.readValue(json, new TypeReference<List<NominatimResult>>() {});
            return results.stream()
                    .map(r -> new PlaceSuggestion(r.display_name(), Double.parseDouble(r.lat()), Double.parseDouble(r.lon())))
                    .toList();
        } catch (IOException | NumberFormatException | NullPointerException e) {
            // NumberFormatException/NullPointerException: lat/lon ausentes ou não
            // numéricos num 200 do Nominatim — tão "não confiável" quanto um erro
            // de rede, e precisa cair no mesmo tratamento (não um 500 opaco).
            throw new PlaceProviderUnavailableException("Resposta do serviço de geocodificação em formato inesperado.");
        }
    }

    // Nomes de campo batem exatamente com o JSON do Nominatim (display_name/lat/lon),
    // dispensando anotações @JsonProperty para o binding.
    private record NominatimResult(String display_name, String lat, String lon) {
    }
}
