package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.security.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Covers the PUT /users/{id} self-service path for agents (CPS-17): before this,
 * the endpoint only knew about ClientUser and always 404'd for an agent's own id,
 * which is why editing your own agent profile silently failed regardless of input.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ClientUserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private AgentUserRepository agentUserRepository;

    private AgentUser createAgent(String email) {
        AgentUser agent = new AgentUser();
        agent.setName("Agente Original");
        agent.setEmail(email);
        agent.setCpf("11144477735");
        agent.setCnpj("");
        agent.setPhone("11999999999");
        agent.setPassword("hash-nao-usado-neste-teste");
        return agentUserRepository.save(agent);
    }

    @Test
    void updatesAgentOwnProfileWhenTokenMatches() throws Exception {
        AgentUser agent = createAgent("self.update@compass.com");
        String token = jwtUtil.generateToken(agent.getEmail(), "AGENTE", agent.getId());

        Map<String, Object> body = new HashMap<>();
        body.put("id", String.valueOf(agent.getId()));
        body.put("name", "Nome Atualizado");
        body.put("phoneNumber", "11888887777");

        mockMvc.perform(put("/users/" + agent.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.name").value("Nome Atualizado"))
                .andExpect(jsonPath("$.data.phoneNumber").value("11888887777"));
    }

    @Test
    void rejectsUpdateWithoutAuthorizationHeader() throws Exception {
        AgentUser agent = createAgent("no.auth@compass.com");

        Map<String, Object> body = new HashMap<>();
        body.put("id", String.valueOf(agent.getId()));
        body.put("name", "Tentativa Sem Token");

        mockMvc.perform(put("/users/" + agent.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isForbidden());
    }

    @Test
    void rejectsUpdateWhenTokenBelongsToAnotherAgent() throws Exception {
        AgentUser owner = createAgent("owner@compass.com");
        AgentUser intruder = createAgent("intruder@compass.com");
        String intruderToken = jwtUtil.generateToken(intruder.getEmail(), "AGENTE", intruder.getId());

        Map<String, Object> body = new HashMap<>();
        body.put("id", String.valueOf(owner.getId()));
        body.put("name", "Tentativa De Outro Agente");

        mockMvc.perform(put("/users/" + owner.getId())
                        .header("Authorization", "Bearer " + intruderToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Você só pode atualizar os seus próprios dados."));
    }
}
