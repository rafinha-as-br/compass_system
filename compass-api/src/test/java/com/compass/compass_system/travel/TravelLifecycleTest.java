package com.compass.compass_system.travel;

import com.compass.compass_system.company.AgentFixtures;
import com.compass.compass_system.company.CompanyRepository;
import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
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


import java.time.Instant;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Transições "Iniciar viagem" e "Finalizar viagem" da viagem (CPS-170). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class TravelLifecycleTest {

    private static final String READY = "itinerary_created";

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private CompanyRepository companyRepository;
    @Autowired private AgentUserRepository agentRepository;
    @Autowired private ClientUserRepository clientRepository;
    @Autowired private TravelRepository travelRepository;

    private AgentUser agent;
    private AgentUser otherAgent;
    private ClientUser client;
    private ClientUser otherClient;

    @BeforeEach
    void setUp() {
        agent = findOrCreateAgent("Agente Ciclo", "agente@ciclo-a.com");
        otherAgent = findOrCreateAgent("Agente Outra", "agente@ciclo-b.com");
        client = findOrCreateClient(agent, "Cliente Um", "um@ciclo-a.com");
        otherClient = findOrCreateClient(agent, "Cliente Dois", "dois@ciclo-a.com");
        travelRepository.deleteAll(travelRepository.findByCompany_Id(agent.getCompany().getId()));
        travelRepository.deleteAll(travelRepository.findByCompany_Id(otherAgent.getCompany().getId()));
    }

    private AgentUser findOrCreateAgent(String name, String email) {
        return agentRepository.findByEmail(email).orElseGet(
                () -> AgentFixtures.saveOwner(agentRepository, companyRepository, name, email, "hash"));
    }

    private ClientUser findOrCreateClient(AgentUser owner, String name, String email) {
        return clientRepository.findByEmail(email).orElseGet(
                () -> AgentFixtures.saveClient(clientRepository, owner.getCompany(), name, email, "hash"));
    }

    private Travel saveTravel(AgentUser owner, ClientUser forClient, String travelStatus, boolean prepared) {
        Travel travel = new Travel();
        travel.setCompany(owner.getCompany());
        travel.setClientName(forClient.getName());
        travel.setClientId(forClient.getId());
        travel.setAgentId(owner.getId());
        travel.setTravelName("Viagem " + travelStatus);
        travel.setTravelStatus(travelStatus);
        travel.setPrepared(prepared);
        return travelRepository.save(travel);
    }

    private String agentToken(AgentUser who) {
        return "Bearer " + jwtUtil.generateToken(who.getEmail(), "AGENTE", who.getId());
    }

    private String clientToken(ClientUser who) {
        return "Bearer " + jwtUtil.generateToken(who.getEmail(), "CLIENTE", who.getId());
    }

    private Travel reload(Travel travel) {
        return travelRepository.findById(travel.getId()).orElseThrow();
    }

    // ─── Iniciar ────────────────────────────────────────────────────────────────

    @Test
    void agentStartsPreparedTravel() throws Exception {
        Travel travel = saveTravel(agent, client, READY, true);

        mockMvc.perform(post("/travels/" + travel.getId() + "/start").header("Authorization", agentToken(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.travelStatus").value("travel_started"))
                .andExpect(jsonPath("$.finishedAt").doesNotExist());

        assertEquals("travel_started", reload(travel).getTravelStatus());
    }

    @Test
    void clientStartsPreparedTravel() throws Exception {
        Travel travel = saveTravel(agent, client, READY, true);

        mockMvc.perform(post("/travels/" + travel.getId() + "/start").header("Authorization", clientToken(client)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.travelStatus").value("travel_started"));
    }

    @Test
    void rejectsStartWhenItineraryNotPublished() throws Exception {
        Travel travel = saveTravel(agent, client, READY, false);

        mockMvc.perform(post("/travels/" + travel.getId() + "/start").header("Authorization", agentToken(agent)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A viagem ainda não está pronta para ser iniciada."));

        assertEquals(READY, reload(travel).getTravelStatus());
    }

    @Test
    void rejectsStartWhenAlreadyStartedOrFinished() throws Exception {
        Travel started = saveTravel(agent, client, "travel_started", true);
        Travel finished = saveTravel(agent, otherClient, "travel_finished", true);

        mockMvc.perform(post("/travels/" + started.getId() + "/start").header("Authorization", agentToken(agent)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A viagem já foi iniciada."));
        mockMvc.perform(post("/travels/" + finished.getId() + "/start").header("Authorization", agentToken(agent)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A viagem já foi finalizada."));

        assertEquals("travel_finished", reload(finished).getTravelStatus());
        assertNull(reload(finished).getFinishedAt());
    }

    @Test
    void blocksSecondTravelInProgressForSameClient() throws Exception {
        Travel first = saveTravel(agent, client, READY, true);
        Travel second = saveTravel(agent, client, READY, true);
        String token = agentToken(agent);

        mockMvc.perform(post("/travels/" + first.getId() + "/start").header("Authorization", token))
                .andExpect(status().isOk());
        mockMvc.perform(post("/travels/" + second.getId() + "/start").header("Authorization", token))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(
                        "Já existe uma viagem em andamento para este cliente. Finalize-a antes de iniciar outra."));
        assertEquals(READY, reload(second).getTravelStatus());

        // Finishing the one in progress frees the client to start the next.
        mockMvc.perform(post("/travels/" + first.getId() + "/finish").header("Authorization", token))
                .andExpect(status().isOk());
        mockMvc.perform(post("/travels/" + second.getId() + "/start").header("Authorization", token))
                .andExpect(status().isOk());
    }

    @Test
    void anotherClientOfTheSameCompanyCanStartInParallel() throws Exception {
        Travel mine = saveTravel(agent, client, READY, true);
        Travel theirs = saveTravel(agent, otherClient, READY, true);
        String token = agentToken(agent);

        mockMvc.perform(post("/travels/" + mine.getId() + "/start").header("Authorization", token))
                .andExpect(status().isOk());
        mockMvc.perform(post("/travels/" + theirs.getId() + "/start").header("Authorization", token))
                .andExpect(status().isOk());
    }

    @Test
    void usesClientNameWhenTravelHasNoClientId() throws Exception {
        Travel inProgress = saveTravel(agent, client, "travel_started", true);
        inProgress.setClientId(null);
        travelRepository.save(inProgress);
        Travel legacy = saveTravel(agent, client, READY, true);
        legacy.setClientId(null);
        travelRepository.save(legacy);

        mockMvc.perform(post("/travels/" + legacy.getId() + "/start").header("Authorization", agentToken(agent)))
                .andExpect(status().isBadRequest());
    }

    // ─── Finalizar ──────────────────────────────────────────────────────────────

    @Test
    void finishesTravelInProgressRecordingTheDate() throws Exception {
        Travel travel = saveTravel(agent, client, "travel_started", true);
        Instant before = Instant.now();

        mockMvc.perform(post("/travels/" + travel.getId() + "/finish").header("Authorization", clientToken(client)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.travelStatus").value("travel_finished"))
                .andExpect(jsonPath("$.finishedAt").isNotEmpty());

        Travel saved = reload(travel);
        assertEquals("travel_finished", saved.getTravelStatus());
        assertNotNull(saved.getFinishedAt());
        assertFalse(saved.getFinishedAt().isBefore(before.minusSeconds(1)));
    }

    @Test
    void agentFinishesTravelInProgress() throws Exception {
        Travel travel = saveTravel(agent, client, "travel_started", true);

        mockMvc.perform(post("/travels/" + travel.getId() + "/finish").header("Authorization", agentToken(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.travelStatus").value("travel_finished"));
    }

    @Test
    void rejectsFinishUnlessInProgress() throws Exception {
        Travel notStarted = saveTravel(agent, client, READY, true);
        Travel alreadyFinished = saveTravel(agent, otherClient, "travel_finished", true);
        String token = agentToken(agent);

        mockMvc.perform(post("/travels/" + notStarted.getId() + "/finish").header("Authorization", token))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Só é possível finalizar uma viagem em andamento."));
        mockMvc.perform(post("/travels/" + alreadyFinished.getId() + "/finish").header("Authorization", token))
                .andExpect(status().isBadRequest());

        assertNull(reload(notStarted).getFinishedAt());
        assertEquals(READY, reload(notStarted).getTravelStatus());
    }

    // ─── Isolamento por empresa e leituras ─────────────────────────────────────

    @Test
    void anotherCompanyCannotStartOrFinish() throws Exception {
        Travel ready = saveTravel(agent, client, READY, true);
        Travel inProgress = saveTravel(agent, otherClient, "travel_started", true);
        String foreign = agentToken(otherAgent);

        mockMvc.perform(post("/travels/" + ready.getId() + "/start").header("Authorization", foreign))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/travels/" + inProgress.getId() + "/finish").header("Authorization", foreign))
                .andExpect(status().isNotFound());

        assertEquals(READY, reload(ready).getTravelStatus());
        assertEquals("travel_started", reload(inProgress).getTravelStatus());
    }

    @Test
    void transitionsRequireAuthentication() throws Exception {
        Travel travel = saveTravel(agent, client, READY, true);

        mockMvc.perform(post("/travels/" + travel.getId() + "/start")).andExpect(status().isForbidden());
        mockMvc.perform(post("/travels/" + travel.getId() + "/finish")).andExpect(status().isForbidden());
    }

    @Test
    void readingATravelDoesNotChangeItsState() throws Exception {
        Travel travel = saveTravel(agent, client, READY, true);
        String token = agentToken(agent);

        mockMvc.perform(get("/travels/" + travel.getId()).header("Authorization", token)).andExpect(status().isOk());
        mockMvc.perform(get("/travels").header("Authorization", token)).andExpect(status().isOk());
        mockMvc.perform(get("/travels/client/" + client.getName()).header("Authorization", token))
                .andExpect(status().isOk());

        assertEquals(READY, reload(travel).getTravelStatus());
    }

    // ─── finishedAt só muda pelo "finalizar" ───────────────────────────────────

    @Test
    void fullUpdateKeepsTheRecordedFinishDate() throws Exception {
        Travel travel = saveTravel(agent, client, "travel_started", true);
        String token = agentToken(agent);
        mockMvc.perform(post("/travels/" + travel.getId() + "/finish").header("Authorization", token))
                .andExpect(status().isOk());
        Instant recorded = reload(travel).getFinishedAt();

        Travel forged = new Travel();
        forged.setClientName(client.getName());
        forged.setClientId(client.getId());
        forged.setAgentId(agent.getId());
        forged.setTravelName("Renomeada");
        forged.setTravelStatus("travel_finished");
        forged.setFinishedAt(Instant.parse("2020-01-01T00:00:00Z"));
        mockMvc.perform(put("/travels/" + travel.getId())
                        .header("Authorization", token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(forged)))
                .andExpect(status().isOk());
        assertEquals(recorded, reload(travel).getFinishedAt());

        forged.setFinishedAt(null);
        mockMvc.perform(put("/travels/" + travel.getId())
                        .header("Authorization", token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(forged)))
                .andExpect(status().isOk());
        assertEquals(recorded, reload(travel).getFinishedAt());
    }

    @Test
    void createIgnoresAClientSuppliedFinishDate() throws Exception {
        Travel body = new Travel();
        body.setClientName(client.getName());
        body.setClientId(client.getId());
        body.setAgentId(agent.getId());
        body.setTravelName("Nova");
        body.setTravelStatus("route_created");
        body.setFinishedAt(Instant.parse("2020-01-01T00:00:00Z"));

        mockMvc.perform(post("/travels")
                        .header("Authorization", agentToken(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.finishedAt").doesNotExist());
    }
}
