package com.compass.compass_system.travel;

import com.compass.compass_system.itinerary.*;
import com.compass.compass_system.transport.Airplane;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class TravelControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    // Shared state between ordered tests
    static String createdTravelId;

    // ─── Test 1: POST /travels ──────────────────────────────────────────────────
    @Test
    @Order(1)
    void shouldCreateTravel() throws Exception {
        Travel travel = new Travel();
        travel.setClientName("Maria Silva");
        travel.setTravelName("Lisbon 2025");
        travel.setTravelStatus("route_created");

        RoutePlan routePlan = new RoutePlan();
        routePlan.setStartDate("2025-08-01T00:00:00.000Z");
        routePlan.setFinishDate("2025-08-15T00:00:00.000Z");
        routePlan.setStartLocation("São Paulo");
        routePlan.setDestination("Lisbon");

        InterestPoint ip = new InterestPoint();
        ip.setName("Belém Tower");
        ip.setDescription("Historic tower by the Tagus river");
        routePlan.setInterestPoints(List.of(ip));
        travel.setRoutePlan(routePlan);

        Person participant = new Person();
        participant.setName("Maria Silva");
        participant.setAge("34");
        participant.setSex("F");
        travel.setParticipants(List.of(participant));

        MvcResult result = mockMvc.perform(post("/travels")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(travel)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.clientName").value("Maria Silva"))
                .andExpect(jsonPath("$.travelStatus").value("route_created"))
                .andExpect(jsonPath("$.routePlan.id").isNotEmpty())
                .andExpect(jsonPath("$.routePlan.interestPoints[0].id").isNotEmpty())
                .andExpect(jsonPath("$.participants[0].id").isNotEmpty())
                .andReturn();

        Travel created = objectMapper.readValue(result.getResponse().getContentAsString(), Travel.class);
        createdTravelId = created.getId();
    }

    // ─── Test 2: GET /travels/{id} ─────────────────────────────────────────────
    @Test
    @Order(2)
    void shouldGetTravel() throws Exception {
        mockMvc.perform(get("/travels/" + createdTravelId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(createdTravelId))
                .andExpect(jsonPath("$.travelName").value("Lisbon 2025"));
    }

    // ─── Test 3: PUT /travels/{id} ─────────────────────────────────────────────
    @Test
    @Order(3)
    void shouldUpdateTravel() throws Exception {
        Travel travel = new Travel();
        travel.setClientName("Maria Silva Updated");
        travel.setTravelName("Lisbon 2025 — Extended");
        travel.setTravelStatus("route_created");

        RoutePlan routePlan = new RoutePlan();
        routePlan.setStartDate("2025-08-01T00:00:00.000Z");
        routePlan.setFinishDate("2025-08-20T00:00:00.000Z");
        routePlan.setStartLocation("São Paulo");
        routePlan.setDestination("Lisbon");
        travel.setRoutePlan(routePlan);

        mockMvc.perform(put("/travels/" + createdTravelId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(travel)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.clientName").value("Maria Silva Updated"))
                .andExpect(jsonPath("$.routePlan.finishDate").value("2025-08-20T00:00:00.000Z"));
    }

    // ─── Test 4: PUT /travels/{id}/itinerary ───────────────────────────────────
    @Test
    @Order(4)
    void shouldUpsertItinerary() throws Exception {
        Itinerary itinerary = new Itinerary();
        itinerary.setAgentName("Carlos Agent");

        // TravelSegment step with Airplane
        TravelSegment segment = new TravelSegment();
        segment.setTitle("Flight to Lisbon");
        segment.setStartDate("2025-08-01T10:00:00.000Z");
        segment.setFinishDate("2025-08-01T22:00:00.000Z");
        segment.setFinished(false);
        segment.setStartPoint("GRU - São Paulo");
        segment.setFinishPoint("LIS - Lisbon");

        Airplane airplane = new Airplane();
        airplane.setFlightNumber("TP045");
        airplane.setCompanyName("TAP Air Portugal");
        airplane.setFlightDate("2025-08-01T10:00:00.000Z");
        airplane.setDepartureGate("A12");
        airplane.setDepartureAirport("GRU");
        airplane.setArrivalAirport("LIS");
        segment.setTransport(airplane);

        // Hosting step
        Hosting hosting = new Hosting();
        hosting.setTitle("Hotel Avenida");
        hosting.setStartDate("2025-08-01T23:00:00.000Z");
        hosting.setFinishDate("2025-08-10T12:00:00.000Z");
        hosting.setFinished(false);
        hosting.setName("Hotel Avenida Palace");
        hosting.setAddress("Rua 1 de Dezembro 123, Lisbon");
        hosting.setCheckIn("2025-08-01T15:00:00.000Z");
        hosting.setCheckOut("2025-08-10T12:00:00.000Z");

        // Stop step with experiences
        Stop stop = new Stop();
        stop.setTitle("Visit Belém Tower");
        stop.setStartDate("2025-08-03T09:00:00.000Z");
        stop.setFinishDate("2025-08-03T12:00:00.000Z");
        stop.setFinished(false);
        stop.setName("Belém Tower");
        stop.setDescription("UNESCO World Heritage Site");
        stop.setExperiences(List.of("photography", "sightseeing"));

        itinerary.setSteps(List.of(segment, hosting, stop));

        mockMvc.perform(put("/travels/" + createdTravelId + "/itinerary")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(itinerary)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.agentName").value("Carlos Agent"))
                .andExpect(jsonPath("$.steps[0].type").value("travel_segment"))
                .andExpect(jsonPath("$.steps[0].transport.type").value("airplane"))
                .andExpect(jsonPath("$.steps[0].transport.flightNumber").value("TP045"))
                .andExpect(jsonPath("$.steps[1].type").value("hosting"))
                .andExpect(jsonPath("$.steps[2].type").value("stop"))
                .andExpect(jsonPath("$.steps[2].experiences[0]").value("photography"));

        // Also verify that the travelStatus was transitioned
        mockMvc.perform(get("/travels/" + createdTravelId))
                .andExpect(jsonPath("$.travelStatus").value("itinerary_created"));
    }

    // ─── Test 5: DELETE /travels/{id} ──────────────────────────────────────────
    @Test
    @Order(5)
    void shouldDeleteTravel() throws Exception {
        mockMvc.perform(delete("/travels/" + createdTravelId))
                .andExpect(status().isNoContent());

        // Confirm it's gone
        mockMvc.perform(get("/travels/" + createdTravelId))
                .andExpect(status().isNotFound());
    }
}
