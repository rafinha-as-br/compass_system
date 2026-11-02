package com.compass.compass_system.travel;

import com.compass.compass_system.company.AgentFixtures;
import com.compass.compass_system.company.CompanyRepository;
import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.itinerary.Itinerary;
import com.compass.compass_system.itinerary.PlaceholderStep;
import com.compass.compass_system.notification.NotificationEvent;
import com.compass.compass_system.notification.NotificationType;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.security.JwtUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.event.ApplicationEvents;
import org.springframework.test.context.event.RecordApplicationEvents;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Salvar o itinerário grava só um rascunho, invisível ao cliente; a publicação
 * e a notificação acontecem somente em "Preparar viagem" (CPS-191).
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@RecordApplicationEvents
class TravelItineraryPublicationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private CompanyRepository companyRepository;
    @Autowired private AgentUserRepository agentRepository;
    @Autowired private ClientUserRepository clientRepository;
    @Autowired private TravelRepository travelRepository;
    @Autowired private ApplicationEvents events;

    private String agentToken;
    private String clientToken;
    private String travelId;

    @BeforeEach
    void setUp() {
        String domain = "publicacao-" + System.nanoTime() + ".com";
        AgentUser agent = AgentFixtures.saveOwner(agentRepository, companyRepository, "Agente", "agente@" + domain, "hash");
        ClientUser client = AgentFixtures.saveClient(clientRepository, agent.getCompany(), "Cliente", "cliente@" + domain, "hash");
        agentToken = "Bearer " + jwtUtil.generateToken(agent.getEmail(), "AGENTE", agent.getId());
        clientToken = "Bearer " + jwtUtil.generateToken(client.getEmail(), "CLIENTE", client.getId());

        Travel travel = new Travel();
        travel.setCompany(agent.getCompany());
        travel.setClientName(client.getName());
        travel.setClientId(client.getId());
        travel.setAgentId(agent.getId());
        travel.setTravelName("Lisboa");
        travel.setTravelStatus("route_created");
        travelId = travelRepository.save(travel).getId();
    }

    private void saveItinerary(String stepTitle) throws Exception {
        PlaceholderStep step = new PlaceholderStep();
        step.setTitle(stepTitle);
        Itinerary itinerary = new Itinerary();
        itinerary.setAgentName("Agente");
        itinerary.setSteps(List.of(step));
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(itinerary)))
                .andExpect(status().isOk());
    }

    private JsonNode agentView() throws Exception {
        String body = mockMvc.perform(get("/travels/" + travelId).header("Authorization", agentToken))
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(body);
    }

    /** "Preparar viagem": o Travel Matrix devolve a viagem inteira com prepared = true. */
    private void prepareTravel() throws Exception {
        JsonNode travel = agentView();
        ((com.fasterxml.jackson.databind.node.ObjectNode) travel).put("prepared", true);
        mockMvc.perform(put("/travels/" + travelId)
                        .header("Authorization", agentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(travel)))
                .andExpect(status().isOk());
    }

    private List<NotificationType> notificationTypes() {
        return events.stream(NotificationEvent.class).map(NotificationEvent::type).toList();
    }

    @Test
    void savingOnlyWritesADraftThatTheClientCannotSee() throws Exception {
        saveItinerary("Chegada");

        assertEquals(List.of(), notificationTypes());

        mockMvc.perform(get("/travels/" + travelId).header("Authorization", clientToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.itinerary").value((Object) null))
                .andExpect(jsonPath("$.travelStatus").value("route_created"))
                .andExpect(jsonPath("$.itineraryDraftPending").doesNotExist())
                .andExpect(jsonPath("$.publishedItinerary").doesNotExist());

        JsonNode agent = agentView();
        assertEquals("Chegada", agent.at("/itinerary/steps/0/title").asText());
        assertEquals(false, agent.get("prepared").asBoolean());
        assertEquals(true, agent.get("publishedItinerary").isNull());
    }

    @Test
    void preparingPublishesACopyAndNotifiesTheClientOnce() throws Exception {
        saveItinerary("Chegada");
        prepareTravel();

        assertEquals(List.of(NotificationType.ITINERARY_PUBLISHED), notificationTypes());

        mockMvc.perform(get("/travels/" + travelId).header("Authorization", clientToken))
                .andExpect(jsonPath("$.itinerary.steps[0].title").value("Chegada"))
                .andExpect(jsonPath("$.travelStatus").value("itinerary_created"));

        JsonNode agent = agentView();
        assertEquals("Chegada", agent.at("/publishedItinerary/steps/0/title").asText());
        assertNotEquals(agent.at("/itinerary/steps/0/id").asText(),
                agent.at("/publishedItinerary/steps/0/id").asText(),
                "the published copy must not share rows with the draft");
        assertEquals(false, agent.get("itineraryDraftPending").asBoolean());
    }

    @Test
    void editingAPublishedItineraryStaysAPendingDraftUntilRepublished() throws Exception {
        saveItinerary("Chegada");
        prepareTravel();

        saveItinerary("Chegada (editada)");

        // client still sees the published version, nothing new was sent
        assertEquals(List.of(NotificationType.ITINERARY_PUBLISHED), notificationTypes());
        mockMvc.perform(get("/travels/" + travelId).header("Authorization", clientToken))
                .andExpect(jsonPath("$.itinerary.steps[0].title").value("Chegada"));
        assertEquals(true, agentView().get("itineraryDraftPending").asBoolean());

        prepareTravel();

        assertEquals(List.of(NotificationType.ITINERARY_PUBLISHED, NotificationType.ITINERARY_STEP_CHANGED),
                notificationTypes());
        mockMvc.perform(get("/travels/" + travelId).header("Authorization", clientToken))
                .andExpect(jsonPath("$.itinerary.steps[0].title").value("Chegada (editada)"));
        assertEquals(false, agentView().get("itineraryDraftPending").asBoolean());
    }

    @Test
    void resubmittingAPreparedTravelWithoutPendingDraftDoesNotRepublish() throws Exception {
        saveItinerary("Chegada");
        prepareTravel();
        prepareTravel();

        assertEquals(List.of(NotificationType.ITINERARY_PUBLISHED), notificationTypes());
    }

    @Test
    void serverOwnsThePublishedCopyAndThePendingFlag() throws Exception {
        saveItinerary("Chegada");

        JsonNode travel = agentView();
        ((com.fasterxml.jackson.databind.node.ObjectNode) travel).set("publishedItinerary",
                objectMapper.valueToTree(new Itinerary()));
        ((com.fasterxml.jackson.databind.node.ObjectNode) travel).put("itineraryDraftPending", true);
        mockMvc.perform(put("/travels/" + travelId)
                        .header("Authorization", agentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(travel)))
                .andExpect(status().isOk());

        JsonNode after = agentView();
        assertEquals(true, after.get("publishedItinerary").isNull());
        assertEquals(false, after.get("itineraryDraftPending").asBoolean());
    }

    @Test
    void aClientTokenCannotPrepareTheTravel() throws Exception {
        saveItinerary("Chegada");

        JsonNode travel = agentView();
        ((com.fasterxml.jackson.databind.node.ObjectNode) travel).put("prepared", true);
        mockMvc.perform(put("/travels/" + travelId)
                        .header("Authorization", clientToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(travel)))
                .andExpect(status().isOk());

        assertEquals(List.of(), notificationTypes());
        mockMvc.perform(get("/travels/" + travelId).header("Authorization", clientToken))
                .andExpect(jsonPath("$.itinerary").value((Object) null));
        assertEquals(false, agentView().get("prepared").asBoolean());
    }
}
