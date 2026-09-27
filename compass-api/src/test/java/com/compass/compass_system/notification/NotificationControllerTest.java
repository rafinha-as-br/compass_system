package com.compass.compass_system.notification;

import com.compass.compass_system.itinerary.Itinerary;
import com.compass.compass_system.itinerary.Stop;
import com.compass.compass_system.security.JwtUtil;
import com.compass.compass_system.travel.RoutePlan;
import com.compass.compass_system.travel.Travel;
import com.compass.compass_system.travel.TravelRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class NotificationControllerTest {

    private static final long CLIENT_ID = 100L;
    private static final long AGENT_ID = 200L;
    private static final long OTHER_AGENT_ID = 201L;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private TravelRepository travelRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private String travelId;

    private String clientAuthHeader() {
        return "Bearer " + jwtUtil.generateToken("client@matrix.com", "CLIENTE", CLIENT_ID);
    }

    private String agentAuthHeader() {
        return "Bearer " + jwtUtil.generateToken("agent@matrix.com", "AGENTE", AGENT_ID);
    }

    private String otherAgentAuthHeader() {
        return "Bearer " + jwtUtil.generateToken("other-agent@matrix.com", "AGENTE", OTHER_AGENT_ID);
    }

    // Notification creation is async since CPS-146 (Travel*Controller only
    // publishes an event; NotificationConsumer, driven by a real RabbitMQ,
    // is what actually persists it) — polls instead of asserting right after
    // the PUT that triggered it.
    private void awaitNotificationCount(long expectedCount) throws InterruptedException {
        long deadline = System.currentTimeMillis() + 5000;
        while (System.currentTimeMillis() < deadline) {
            if (notificationRepository.count() >= expectedCount) return;
            Thread.sleep(50);
        }
    }

    @BeforeEach
    void setUp() {
        notificationRepository.deleteAll();
        travelRepository.deleteAll();

        Travel travel = new Travel();
        travel.setClientName("Maria Silva");
        travel.setTravelName("Lisbon 2026");
        travel.setTravelStatus("route_created");
        travel.setClientId(CLIENT_ID);
        travel.setAgentId(AGENT_ID);
        travelId = travelRepository.save(travel).getId();
    }

    private Itinerary sampleItinerary() {
        Stop stop = new Stop();
        stop.setTitle("Visit Belem Tower");
        stop.setStartDate("2026-08-03T09:00:00.000Z");
        stop.setFinishDate("2026-08-03T12:00:00.000Z");
        stop.setFinished(false);
        stop.setName("Belem Tower");
        stop.setDescription("UNESCO World Heritage Site");

        Itinerary itinerary = new Itinerary();
        itinerary.setAgentName("Carlos Agent");
        itinerary.setSteps(List.of(stop));
        return itinerary;
    }

    private RoutePlan sampleRoutePlan(String destination) {
        RoutePlan routePlan = new RoutePlan();
        routePlan.setStartDate("2026-08-01T00:00:00.000Z");
        routePlan.setFinishDate("2026-08-15T00:00:00.000Z");
        routePlan.setStartLocation("Sao Paulo");
        routePlan.setDestination(destination);
        return routePlan;
    }

    @Test
    void shouldRequireAuthForNotifications() throws Exception {
        mockMvc.perform(get("/notifications"))
                .andExpect(status().isForbidden());
    }

    @Test
    void publishingItineraryNotifiesOnlyTheClient() throws Exception {
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        awaitNotificationCount(1);

        mockMvc.perform(get("/notifications").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", org.hamcrest.Matchers.hasSize(1)))
                .andExpect(jsonPath("$.content[0].type").value("ITINERARY_PUBLISHED"))
                .andExpect(jsonPath("$.content[0].read").value(false));

        // The agent is not a recipient of this event.
        mockMvc.perform(get("/notifications").header("Authorization", agentAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", org.hamcrest.Matchers.hasSize(0)));
    }

    @Test
    void editingAnAlreadyPublishedItineraryNotifiesAsStepChangedNotPublished() throws Exception {
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        // Waiting for the first event to be fully delivered before firing the
        // second is what actually keeps `createdAt` ordering deterministic —
        // the very first AMQP publish lazily opens the connection/channel,
        // which can otherwise delay it past a second publish that reuses an
        // already-open one.
        awaitNotificationCount(1);

        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        awaitNotificationCount(2);

        mockMvc.perform(get("/notifications").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", org.hamcrest.Matchers.hasSize(2)))
                .andExpect(jsonPath("$.content[0].type").value("ITINERARY_STEP_CHANGED"))
                .andExpect(jsonPath("$.content[1].type").value("ITINERARY_PUBLISHED"));
    }

    @Test
    void creatingThenEditingARouteNotifiesOnlyTheResponsibleAgent() throws Exception {
        mockMvc.perform(put("/travels/" + travelId + "/route")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleRoutePlan("Lisbon"))))
                .andExpect(status().isOk());

        awaitNotificationCount(1);

        mockMvc.perform(get("/notifications").header("Authorization", agentAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", org.hamcrest.Matchers.hasSize(1)))
                .andExpect(jsonPath("$.content[0].type").value("ROUTE_CREATED"));

        // A different agent never sees this travel's notifications.
        mockMvc.perform(get("/notifications").header("Authorization", otherAgentAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", org.hamcrest.Matchers.hasSize(0)));

        mockMvc.perform(put("/travels/" + travelId + "/route")
                        .header("Authorization", clientAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleRoutePlan("Porto"))))
                .andExpect(status().isOk());

        awaitNotificationCount(2);

        mockMvc.perform(get("/notifications").header("Authorization", agentAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", org.hamcrest.Matchers.hasSize(2)))
                .andExpect(jsonPath("$.content[0].type").value("ROUTE_EDITED"));
    }

    @Test
    void markingAsReadPersistsAndDropsUnreadCount() throws Exception {
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        awaitNotificationCount(1);

        mockMvc.perform(get("/notifications/unread-count").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(1));

        String notificationId = notificationRepository.findAll().get(0).getId();

        mockMvc.perform(put("/notifications/" + notificationId + "/read").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.read").value(true));

        mockMvc.perform(get("/notifications/unread-count").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(0));

        // Still read on a fresh fetch — it doesn't revert.
        mockMvc.perform(get("/notifications").header("Authorization", clientAuthHeader()))
                .andExpect(jsonPath("$.content[0].read").value(true));
    }

    @Test
    void cannotMarkAnotherRecipientsNotificationAsRead() throws Exception {
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        awaitNotificationCount(1);
        String notificationId = notificationRepository.findAll().get(0).getId();

        // This notification belongs to the CLIENT recipient, not the agent.
        mockMvc.perform(put("/notifications/" + notificationId + "/read").header("Authorization", agentAuthHeader()))
                .andExpect(status().isNotFound());
    }

    @Test
    void markAllAsReadClearsUnreadCountForThatRecipientOnly() throws Exception {
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());
        mockMvc.perform(put("/travels/" + travelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        awaitNotificationCount(2);

        mockMvc.perform(put("/notifications/read-all").header("Authorization", clientAuthHeader()))
                .andExpect(status().isNoContent());

        mockMvc.perform(get("/notifications/unread-count").header("Authorization", clientAuthHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(0));
    }

    @Test
    void travelWithoutAResolvedRecipientSkipsNotificationSilently() throws Exception {
        Travel legacyTravel = new Travel();
        legacyTravel.setClientName("Cliente Legado");
        legacyTravel.setTravelName("Viagem Legada");
        // clientId/agentId intentionally left null, as a pre-CPS-145 travel would be.
        String legacyTravelId = travelRepository.save(legacyTravel).getId();

        mockMvc.perform(put("/travels/" + legacyTravelId + "/itinerary")
                        .header("Authorization", agentAuthHeader())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sampleItinerary())))
                .andExpect(status().isOk());

        // No positive condition to poll for here (we're confirming an
        // absence) — give the async pipeline a generous window to have
        // processed the event, then assert nothing was created.
        Thread.sleep(1000);
        org.junit.jupiter.api.Assertions.assertEquals(0, notificationRepository.count());
    }
}
