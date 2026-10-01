package com.compass.compass_system.notification.push;

import com.compass.compass_system.security.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class PushTargetControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PushTargetRepository pushTargetRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private String clientAuthHeader() {
        return "Bearer " + jwtUtil.generateToken("client@matrix.com", "CLIENTE", 1L);
    }

    private String agentAuthHeader() {
        return "Bearer " + jwtUtil.generateToken("agent@matrix.com", "AGENTE", 2L);
    }

    @BeforeEach
    void setUp() {
        pushTargetRepository.deleteAll();
    }

    @Test
    void shouldRequireAuthForPushTargets() throws Exception {
        mockMvc.perform(get("/push-targets/vapid-public-key"))
                .andExpect(status().isForbidden());
    }

    @Test
    void exposesTheVapidPublicKey() throws Exception {
        mockMvc.perform(get("/push-targets/vapid-public-key").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.publicKey").isNotEmpty());
    }

    @Test
    void registersAnAndroidTargetForTheAuthenticatedRecipient() throws Exception {
        Map<String, Object> body = Map.of("platform", "ANDROID", "androidEndpoint", "http://ntfy:80/up-compass-client-1");

        mockMvc.perform(post("/push-targets")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.recipientType").value("CLIENT"))
                .andExpect(jsonPath("$.androidEndpoint").value("http://ntfy:80/up-compass-client-1"));
    }

    @Test
    void reregisteringTheSameEndpointReusesTheExistingRowInsteadOfDuplicating() throws Exception {
        Map<String, Object> body = Map.of("platform", "ANDROID", "androidEndpoint", "http://ntfy:80/up-compass-client-1");

        MvcResult first = mockMvc.perform(post("/push-targets")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andReturn();
        String firstId = objectMapper.readTree(first.getResponse().getContentAsString()).get("id").asText();

        // Same device registering again (e.g. app relaunched) — same id back,
        // not a second row.
        mockMvc.perform(post("/push-targets")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(firstId));

        org.junit.jupiter.api.Assertions.assertEquals(1, pushTargetRepository.count());
    }

    @Test
    void registersAWebTargetForTheAuthenticatedRecipient() throws Exception {
        Map<String, Object> body = Map.of(
                "platform", "WEB",
                "webEndpoint", "https://push.example.com/subscription/abc",
                "webP256dh", "BNcRdreALRFXTkOOUHK1EtK2wtaz5Ry4YfYCA_0QTpQtUbVlUls0VJXg7A8u-Ts1XbjhazAkj7I99e8QcYP7DkM",
                "webAuth", "tBHItJI5svbpez7KI4CCXg");

        mockMvc.perform(post("/push-targets")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recipientType").value("AGENT"))
                .andExpect(jsonPath("$.webEndpoint").value("https://push.example.com/subscription/abc"));
    }

    @Test
    void rejectsAnAndroidRegistrationMissingTheEndpoint() throws Exception {
        Map<String, Object> body = Map.of("platform", "ANDROID");

        mockMvc.perform(post("/push-targets")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void unregistersOwnTarget() throws Exception {
        Map<String, Object> body = Map.of("platform", "ANDROID", "androidEndpoint", "http://ntfy:80/up-compass-client-1");
        MvcResult result = mockMvc.perform(post("/push-targets")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andReturn();
        String id = objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();

        mockMvc.perform(delete("/push-targets/" + id).header("Authorization", clientAuthHeader()))
                .andExpect(status().isNoContent());
    }

    @Test
    void cannotUnregisterAnotherRecipientsTarget() throws Exception {
        Map<String, Object> body = Map.of("platform", "ANDROID", "androidEndpoint", "http://ntfy:80/up-compass-client-1");
        MvcResult result = mockMvc.perform(post("/push-targets")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andReturn();
        String id = objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();

        mockMvc.perform(delete("/push-targets/" + id).header("Authorization", agentAuthHeader()))
                .andExpect(status().isNotFound());
    }
}
