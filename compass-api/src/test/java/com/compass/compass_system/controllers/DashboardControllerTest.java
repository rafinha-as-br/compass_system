package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.security.JwtUtil;
import com.compass.compass_system.travel.Travel;
import com.compass.compass_system.travel.TravelRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ClientUserRepository clientUserRepository;

    @Autowired
    private TravelRepository travelRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private String authHeader() {
        return "Bearer " + jwtUtil.generateToken("agent@matrix.com", "AGENTE", 1L);
    }

    @BeforeEach
    void setUp() {
        travelRepository.deleteAll();
        clientUserRepository.deleteAll();

        ClientUser client = new ClientUser();
        client.setName("Maria Cliente");
        client.setEmail("cliente@matrix.com");
        client.setPassword("hash");
        clientUserRepository.save(client);

        Travel travel = new Travel();
        travel.setClientName("Maria Cliente");
        travel.setTravelName("Litoral Norte");
        travelRepository.save(travel);
    }

    @Test
    void statsExposeActiveClientsCountButNotTheRemovedClientList() throws Exception {
        mockMvc.perform(get("/dashboard/stats").header("Authorization", authHeader()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.activeClients").value(1))
                .andExpect(jsonPath("$.data.recentTravels").isArray())
                .andExpect(jsonPath("$.data.recentTravels[0].clientName").value("Maria Cliente"))
                .andExpect(jsonPath("$.data.activeClientsList").doesNotExist());
    }
}
