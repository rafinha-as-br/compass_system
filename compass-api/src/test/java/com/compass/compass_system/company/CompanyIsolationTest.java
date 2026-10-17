package com.compass.compass_system.company;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.security.JwtUtil;
import com.compass.compass_system.travel.Travel;
import com.compass.compass_system.travel.TravelRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Isolamento por empresa de viagens e clientes: duas empresas, agente e cliente (CPS-195). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CompanyIsolationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private CompanyRepository companyRepository;
    @Autowired private AgentUserRepository agentRepository;
    @Autowired private ClientUserRepository clientRepository;
    @Autowired private TravelRepository travelRepository;

    private AgentUser agentA;
    private AgentUser agentB;
    private ClientUser clientA;
    private ClientUser clientB;
    private Travel travelA;
    private Travel travelB;

    @BeforeEach
    void setUp() {
        travelRepository.deleteAll();
        clientRepository.deleteAll();
        agentRepository.deleteAll();

        agentA = AgentFixtures.saveOwner(agentRepository, companyRepository, "Agente A", "a@empresa-a.com", "hash");
        agentB = AgentFixtures.saveOwner(agentRepository, companyRepository, "Agente B", "b@empresa-b.com", "hash");
        clientA = AgentFixtures.saveClient(clientRepository, agentA.getCompany(), "Cliente A", "ca@mail.com", "hash");
        clientB = AgentFixtures.saveClient(clientRepository, agentB.getCompany(), "Cliente B", "cb@mail.com", "hash");
        travelA = saveTravel(agentA, clientA, "Viagem A");
        travelB = saveTravel(agentB, clientB, "Viagem B");
    }

    private Travel saveTravel(AgentUser agent, ClientUser client, String name) {
        Travel travel = new Travel();
        travel.setCompany(agent.getCompany());
        travel.setClientName(client.getName());
        travel.setClientId(client.getId());
        travel.setAgentId(agent.getId());
        travel.setTravelName(name);
        travel.setTravelStatus("route_created");
        return travelRepository.save(travel);
    }

    private String agentToken(AgentUser agent) {
        return "Bearer " + jwtUtil.generateToken(agent.getEmail(), "AGENTE", agent.getId());
    }

    private String clientToken(ClientUser client) {
        return "Bearer " + jwtUtil.generateToken(client.getEmail(), "CLIENTE", client.getId());
    }

    private ResultActions json(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder req,
                               String token, Object body) throws Exception {
        return mockMvc.perform(req.header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    // ─── Viagens: agente ───────────────────────────────────────────────────────

    @Test
    void agentListsOnlyOwnCompanyTravels() throws Exception {
        mockMvc.perform(get("/travels").header("Authorization", agentToken(agentA)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].travelName").value("Viagem A"));

        mockMvc.perform(get("/travels/client/" + clientB.getName()).header("Authorization", agentToken(agentA)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void agentCannotReadOrChangeAnotherCompanysTravel() throws Exception {
        String token = agentToken(agentA);
        String id = travelB.getId();

        mockMvc.perform(get("/travels/" + id).header("Authorization", token)).andExpect(status().isNotFound());
        json(put("/travels/" + id), token, Map.of("travelName", "hack")).andExpect(status().isNotFound());
        mockMvc.perform(delete("/travels/" + id).header("Authorization", token)).andExpect(status().isNotFound());
        json(put("/travels/" + id + "/itinerary"), token, Map.of("agentName", "x")).andExpect(status().isNotFound());
        json(put("/travels/" + id + "/route"), token, Map.of("destination", "x")).andExpect(status().isNotFound());
        json(put("/travels/" + id + "/participants"), token, List.of()).andExpect(status().isNotFound());

        Travel untouched = travelRepository.findById(id).orElseThrow();
        assertEquals("Viagem B", untouched.getTravelName());
    }

    // ─── Viagens: cliente ──────────────────────────────────────────────────────

    @Test
    void clientReadsOwnCompanyTravelButNotAnotherCompanysById() throws Exception {
        String token = clientToken(clientA);

        mockMvc.perform(get("/travels/" + travelA.getId()).header("Authorization", token))
                .andExpect(status().isOk());
        mockMvc.perform(get("/travels/" + travelB.getId()).header("Authorization", token))
                .andExpect(status().isNotFound());
    }

    @Test
    void clientCannotReadAnotherCompanysTravelByClientName() throws Exception {
        mockMvc.perform(get("/travels/client/" + clientB.getName()).header("Authorization", clientToken(clientA)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    // ─── Criação de viagem ─────────────────────────────────────────────────────

    @Test
    void travelCreatedByClientBelongsToTheClientsCompanyAndIgnoresCompanyInTheBody() throws Exception {
        Map<String, Object> body = Map.of(
                "travelName", "Nova",
                "agentId", agentA.getId(),
                "companyId", agentB.getCompany().getId(),
                "company", Map.of("id", agentB.getCompany().getId()));

        String response = json(post("/travels"), clientToken(clientA), body)
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        JsonNode created = objectMapper.readTree(response);
        Travel saved = travelRepository.findById(created.get("id").asText()).orElseThrow();
        assertEquals(agentA.getCompany().getId(), saved.getCompany().getId());
    }

    @Test
    void travelCreatedByAgentBelongsToTheAgentsCompany() throws Exception {
        String response = json(post("/travels"), agentToken(agentA), Map.of("travelName", "Nova"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        Travel saved = travelRepository.findById(objectMapper.readTree(response).get("id").asText()).orElseThrow();
        assertEquals(agentA.getCompany().getId(), saved.getCompany().getId());
    }

    @Test
    void creatingATravelWithAnAgentFromAnotherCompanyIsRefused() throws Exception {
        long before = travelRepository.count();

        json(post("/travels"), clientToken(clientA), Map.of("travelName", "Nova", "agentId", agentB.getId()))
                .andExpect(status().isBadRequest());

        assertEquals(before, travelRepository.count());
    }

    @Test
    void creatingATravelWithAClientFromAnotherCompanyIsRefused() throws Exception {
        json(post("/travels"), agentToken(agentA), Map.of("travelName", "Nova", "clientId", clientB.getId()))
                .andExpect(status().isBadRequest());
    }

    @Test
    void creatingAClientWithAnExistingEmailIsRefused() throws Exception {
        json(post("/users"), agentToken(agentA), Map.of("name", "Dup", "email", "cb@mail.com"))
                .andExpect(status().isBadRequest());

        assertEquals(1, clientRepository.findAll().stream().filter(c -> c.getEmail().equals("cb@mail.com")).count());
    }

    @Test
    void creatingATravelWithAClientProvidedIdCannotOverwriteAnotherCompanysTravel() throws Exception {
        json(post("/travels"), agentToken(agentA), Map.of("id", travelB.getId(), "travelName", "hack"))
                .andExpect(status().isOk());

        Travel untouched = travelRepository.findById(travelB.getId()).orElseThrow();
        assertEquals("Viagem B", untouched.getTravelName());
        assertEquals(agentB.getCompany().getId(), untouched.getCompany().getId());
    }

    @Test
    void updatingATravelKeepsItsCompanyAndRefusesAnAgentFromAnotherCompany() throws Exception {
        String token = agentToken(agentA);

        json(put("/travels/" + travelA.getId()), token,
                Map.of("travelName", "Editada", "agentId", agentA.getId(), "clientId", clientA.getId()))
                .andExpect(status().isOk());
        assertEquals(agentA.getCompany().getId(),
                travelRepository.findByIdAndCompany_Id(travelA.getId(), agentA.getCompany().getId())
                        .orElseThrow().getCompany().getId());

        json(put("/travels/" + travelA.getId()), token,
                Map.of("travelName", "Editada", "agentId", agentB.getId()))
                .andExpect(status().isBadRequest());
    }

    // ─── Clientes ──────────────────────────────────────────────────────────────

    @Test
    void agentListsOnlyOwnCompanyClients() throws Exception {
        mockMvc.perform(get("/users").header("Authorization", agentToken(agentA)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].name").value("Cliente A"));
    }

    @Test
    void agentCannotReadOrChangeAnotherCompanysClient() throws Exception {
        String token = agentToken(agentA);
        String base = "/users/" + clientB.getId();

        mockMvc.perform(get(base).header("Authorization", token)).andExpect(status().isNotFound());
        json(put(base), token, Map.of("name", "hack")).andExpect(status().isNotFound());
        json(post(base + "/deactivate"), token, Map.of("reason", "x")).andExpect(status().isNotFound());
        mockMvc.perform(post(base + "/reset-password").header("Authorization", token)).andExpect(status().isNotFound());
        mockMvc.perform(post(base + "/force-logout").header("Authorization", token)).andExpect(status().isNotFound());

        ClientUser untouched = clientRepository.findById(clientB.getId()).orElseThrow();
        assertEquals("Cliente B", untouched.getName());
        assertTrue(untouched.getIsActive());
        assertEquals("hash", untouched.getPassword());
    }

    @Test
    void clientCreatedByAnAgentIsBornInTheAgentsCompany() throws Exception {
        String response = json(post("/users"), agentToken(agentA),
                Map.of("name", "Novo Cliente", "email", "novo@mail.com", "cpf", "1"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        long id = Long.parseLong(objectMapper.readTree(response).at("/data/id").asText());
        assertEquals(agentA.getCompany().getId(), clientRepository.findById(id).orElseThrow().getCompany().getId());
    }

    @Test
    void clientTokenCannotCreateClients() throws Exception {
        json(post("/users"), clientToken(clientA), Map.of("name", "Intruso", "email", "intruso@mail.com"))
                .andExpect(status().isForbidden());
    }

    @Test
    void clientSelfSignupEndpointIsGone() throws Exception {
        json(post("/api/auth/cadastrar/cliente"), "Bearer x",
                Map.of("name", "Auto", "email", "auto@mail.com", "password", "x"));

        assertTrue(clientRepository.findByEmail("auto@mail.com").isEmpty());
    }
}
