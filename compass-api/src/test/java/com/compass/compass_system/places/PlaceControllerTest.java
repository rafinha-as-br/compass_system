package com.compass.compass_system.places;

import com.compass.compass_system.security.JwtUtil;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class PlaceControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtil jwtUtil;

    // Substitui o serviço real para nenhum teste depender de rede/Nominatim.
    @MockBean
    private PlaceAutocompleteService placeAutocompleteService;

    private String authHeader() {
        return "Bearer " + jwtUtil.generateToken("agent@matrix.com", "AGENTE", 1L);
    }

    @Test
    void shouldReturnSuggestionsForAnAuthenticatedRequest() throws Exception {
        when(placeAutocompleteService.autocomplete(eq("flor")))
                .thenReturn(List.of(new PlaceSuggestion("Florianópolis, SC, Brasil", -27.59, -48.55)));

        mockMvc.perform(get("/places/autocomplete").param("query", "flor").header("Authorization", authHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Florianópolis, SC, Brasil"))
                .andExpect(jsonPath("$[0].latitude").value(-27.59));
    }

    @Test
    void shouldRejectRequestWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/places/autocomplete").param("query", "flor"))
                .andExpect(status().isForbidden());
    }

    @Test
    void shouldReturn503WhenProviderIsUnavailableInsteadOfAnOpaque500() throws Exception {
        when(placeAutocompleteService.autocomplete(eq("flor")))
                .thenThrow(new PlaceProviderUnavailableException("Nominatim indisponível"));

        mockMvc.perform(get("/places/autocomplete").param("query", "flor").header("Authorization", authHeader()))
                .andExpect(status().isServiceUnavailable());
    }
}
