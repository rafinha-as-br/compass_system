package com.compass.compass_system.users;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.travel.RoutePlan;
import com.compass.compass_system.travel.Travel;
import com.compass.compass_system.travel.TravelRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ClientUserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ClientUserRepository clientUserRepository;

    @Autowired
    private AgentUserRepository agentUserRepository;

    @Autowired
    private TravelRepository travelRepository;

    private Long clientId;
    private String agentToken;

    @BeforeEach
    void setUp() throws Exception {
        travelRepository.deleteAll();
        clientUserRepository.deleteAll();
        agentUserRepository.deleteAll();

        ClientUser client = new ClientUser();
        client.setName("Maria Cliente");
        client.setEmail("cliente@matrix.com");
        client.setPassword(BCrypt.hashpw("senha123", BCrypt.gensalt()));
        clientId = clientUserRepository.save(client).getId();

        AgentUser agent = new AgentUser();
        agent.setName("Carlos Agente");
        agent.setEmail("agente@matrix.com");
        agent.setPassword(BCrypt.hashpw("senha123", BCrypt.gensalt()));
        agentUserRepository.save(agent);

        agentToken = login("agente@matrix.com");
    }

    private String login(String email) throws Exception {
        String body = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("email", email, "password", "senha123"))))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).at("/data/token").asText();
    }

    @Test
    void forceLogoutRejectsATokenIssuedBeforeIt() throws Exception {
        String token = login("cliente@matrix.com");

        // JWT "iat" tem granularidade de segundo inteiro — precisa passar de um
        // segundo real para o force-logout ficar depois do "iat" do token.
        Thread.sleep(1100);

        mockMvc.perform(get("/users/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("cliente@matrix.com"));

        mockMvc.perform(post("/users/" + clientId + "/force-logout")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"));

        mockMvc.perform(get("/users/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    void forceLogoutDoesNotAffectATokenIssuedAfterIt() throws Exception {
        mockMvc.perform(post("/users/" + clientId + "/force-logout")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk());

        Thread.sleep(1100);
        String newToken = login("cliente@matrix.com");

        mockMvc.perform(get("/users/me").header("Authorization", "Bearer " + newToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("cliente@matrix.com"));
    }

    @Test
    void forceLogoutOnUnknownClientReturnsNotFound() throws Exception {
        mockMvc.perform(post("/users/999999/force-logout")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isNotFound());
    }

    @Test
    void getUserByIdIncludesTravelsAndStats() throws Exception {
        saveTravel("Maria Cliente", "Lisboa");
        saveTravel("Maria Cliente", "Lisboa");
        saveTravel("Maria Cliente", "Porto");

        mockMvc.perform(get("/users/" + clientId).header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.travels.length()").value(3))
                .andExpect(jsonPath("$.data.stats.totalTravels").value(3))
                .andExpect(jsonPath("$.data.stats.uniqueDestinationsCount").value(2));
    }

    @Test
    void getUserByIdWithNoTravelsReturnsEmptyTravelsAndZeroStats() throws Exception {
        mockMvc.perform(get("/users/" + clientId).header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.travels.length()").value(0))
                .andExpect(jsonPath("$.data.stats.totalTravels").value(0))
                .andExpect(jsonPath("$.data.stats.uniqueDestinationsCount").value(0));
    }

    private void saveTravel(String clientName, String destination) {
        RoutePlan routePlan = new RoutePlan();
        routePlan.setStartDate("2026-10-01T00:00:00.000Z");
        routePlan.setFinishDate("2026-10-10T00:00:00.000Z");
        routePlan.setStartLocation("São Paulo");
        routePlan.setDestination(destination);

        Travel travel = new Travel();
        travel.setClientName(clientName);
        travel.setTravelName("Viagem a " + destination);
        travel.setTravelStatus("route_created");
        travel.setRoutePlan(routePlan);

        travelRepository.save(travel);
    }
}
