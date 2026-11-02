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
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Observação por ponto de interesse (CPS-180). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class TravelInterestPointObservationTest {

    private static final String TOO_LONG_MESSAGE =
            "A observação de um ponto de interesse pode ter no máximo 500 caracteres.";

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private CompanyRepository companyRepository;
    @Autowired private AgentUserRepository agentRepository;
    @Autowired private ClientUserRepository clientRepository;
    @Autowired private TravelRepository travelRepository;

    private AgentUser agent;
    private ClientUser client;

    @BeforeEach
    void setUp() {
        agent = agentRepository.findByEmail("agente@obs-a.com").orElseGet(
                () -> AgentFixtures.saveOwner(agentRepository, companyRepository, "Agente Obs", "agente@obs-a.com", "hash"));
        client = clientRepository.findByEmail("cliente@obs-a.com").orElseGet(
                () -> AgentFixtures.saveClient(clientRepository, agent.getCompany(), "Cliente Obs", "cliente@obs-a.com", "hash"));
        travelRepository.deleteAll(travelRepository.findByCompany_Id(agent.getCompany().getId()));
    }

    private String agentToken() {
        return "Bearer " + jwtUtil.generateToken(agent.getEmail(), "AGENTE", agent.getId());
    }

    private String clientToken() {
        return "Bearer " + jwtUtil.generateToken(client.getEmail(), "CLIENTE", client.getId());
    }

    private InterestPoint point(String name, String observation) {
        InterestPoint point = new InterestPoint();
        point.setName(name);
        point.setDescription("desc " + name);
        point.setObservation(observation);
        return point;
    }

    private RoutePlan route(InterestPoint... points) {
        RoutePlan routePlan = new RoutePlan();
        routePlan.setStartDate("2026-12-01T00:00:00.000Z");
        routePlan.setFinishDate("2026-12-10T00:00:00.000Z");
        routePlan.setStartLocation("São Paulo");
        routePlan.setDestination("Lisboa");
        routePlan.setInterestPoints(List.of(points));
        return routePlan;
    }

    private Travel travelBody(RoutePlan routePlan) {
        Travel travel = new Travel();
        travel.setClientName(client.getName());
        travel.setClientId(client.getId());
        travel.setAgentId(agent.getId());
        travel.setTravelName("Lisboa");
        travel.setTravelStatus("route_created");
        travel.setObservations("Observação geral da viagem");
        travel.setRoutePlan(routePlan);
        return travel;
    }

    private ResultActions send(MockHttpServletRequestBuilder req, String token, Object body) throws Exception {
        return mockMvc.perform(req.header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private Travel createTravel(RoutePlan routePlan) throws Exception {
        String json = send(post("/travels"), clientToken(), travelBody(routePlan))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readValue(json, Travel.class);
    }

    @Test
    void persistsAnObservationPerPointAndLeavesThoseWithoutOneEmpty() throws Exception {
        Travel created = createTravel(route(point("Torre de Belém", "Chegar cedo"), point("Alfama", null)));

        mockMvc.perform(get("/travels/" + created.getId()).header("Authorization", agentToken()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.routePlan.interestPoints[0].observation").value("Chegar cedo"))
                .andExpect(jsonPath("$.routePlan.interestPoints[1].observation").doesNotExist());
    }

    @Test
    void generalTripObservationKeepsLivingNextToThePointOnes() throws Exception {
        Travel created = createTravel(route(point("Torre de Belém", "Chegar cedo")));

        mockMvc.perform(get("/travels/" + created.getId()).header("Authorization", agentToken()))
                .andExpect(jsonPath("$.observations").value("Observação geral da viagem"))
                .andExpect(jsonPath("$.routePlan.interestPoints[0].observation").value("Chegar cedo"));
    }

    @Test
    void agentEditsAPointObservationThroughTheRouteUpsertAndTheClientSeesIt() throws Exception {
        Travel created = createTravel(route(point("Torre de Belém", "Chegar cedo")));
        RoutePlan edited = route(point("Torre de Belém", "Reservar ingresso online"));

        send(put("/travels/" + created.getId() + "/route"), agentToken(), edited)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.interestPoints[0].observation").value("Reservar ingresso online"));

        mockMvc.perform(get("/travels/" + created.getId()).header("Authorization", clientToken()))
                .andExpect(jsonPath("$.routePlan.interestPoints[0].observation").value("Reservar ingresso online"))
                .andExpect(jsonPath("$.observations").value("Observação geral da viagem"));
    }

    @Test
    void clientEditsAndClearsAnObservation() throws Exception {
        Travel created = createTravel(route(point("Torre de Belém", "Chegar cedo")));

        send(put("/travels/" + created.getId() + "/route"), clientToken(), route(point("Torre de Belém", "   ")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.interestPoints[0].observation").doesNotExist());
    }

    @Test
    void acceptsExactlyTheLimitAndRejectsOneMore() throws Exception {
        String atLimit = "a".repeat(InterestPoint.OBSERVATION_MAX_LENGTH);
        String overLimit = atLimit + "b";

        Travel created = createTravel(route(point("Torre de Belém", atLimit)));

        send(put("/travels/" + created.getId() + "/route"), agentToken(), route(point("Torre de Belém", overLimit)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(TOO_LONG_MESSAGE));

        // The rejected edit left the stored text untouched.
        mockMvc.perform(get("/travels/" + created.getId()).header("Authorization", agentToken()))
                .andExpect(jsonPath("$.routePlan.interestPoints[0].observation").value(atLimit));
    }

    @Test
    void rejectsAnOverLimitObservationOnCreateAndOnFullUpdate() throws Exception {
        String overLimit = "a".repeat(InterestPoint.OBSERVATION_MAX_LENGTH + 1);

        send(post("/travels"), clientToken(), travelBody(route(point("Torre de Belém", overLimit))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(TOO_LONG_MESSAGE));

        Travel created = createTravel(route(point("Torre de Belém", "ok")));
        send(put("/travels/" + created.getId()), agentToken(), travelBody(route(point("Torre de Belém", overLimit))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(TOO_LONG_MESSAGE));
    }

    @Test
    void otherCompanyCannotEditAnObservation() throws Exception {
        Travel created = createTravel(route(point("Torre de Belém", "Chegar cedo")));
        AgentUser foreign = agentRepository.findByEmail("agente@obs-b.com").orElseGet(
                () -> AgentFixtures.saveOwner(agentRepository, companyRepository, "Agente Outra", "agente@obs-b.com", "hash"));
        String token = "Bearer " + jwtUtil.generateToken(foreign.getEmail(), "AGENTE", foreign.getId());

        send(put("/travels/" + created.getId() + "/route"), token, route(point("Torre de Belém", "hack")))
                .andExpect(status().isNotFound());

        mockMvc.perform(get("/travels/" + created.getId()).header("Authorization", agentToken()))
                .andExpect(jsonPath("$.routePlan.interestPoints[0].observation").value("Chegar cedo"));
    }
}
