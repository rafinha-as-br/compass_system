package com.compass.compass_system.auth;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AgentUserRepository agentUserRepository;

    @Autowired
    private ClientUserRepository clientUserRepository;

    @BeforeEach
    void setUp() {
        agentUserRepository.deleteAll();
        clientUserRepository.deleteAll();

        AgentUser agent = new AgentUser();
        agent.setName("Carlos Agente");
        agent.setEmail("agente@matrix.com");
        agent.setPassword(BCrypt.hashpw("senha123", BCrypt.gensalt()));
        agentUserRepository.save(agent);

        ClientUser client = new ClientUser();
        client.setName("Maria Cliente");
        client.setEmail("cliente@matrix.com");
        client.setPassword(BCrypt.hashpw("senha123", BCrypt.gensalt()));
        clientUserRepository.save(client);
    }

    @Test
    void unifiedLoginWithoutExpectedUserTypeAcceptsAgent() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(
                        Map.of("email", "agente@matrix.com", "password", "senha123"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.userType").value("AGENTE"));
    }

    @Test
    void unifiedLoginWithoutExpectedUserTypeAcceptsClient() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(
                        Map.of("email", "cliente@matrix.com", "password", "senha123"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.userType").value("CLIENTE"));
    }

    @Test
    void unifiedLoginWithExpectedUserTypeAgenteAcceptsAgent() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of(
                        "email", "agente@matrix.com",
                        "password", "senha123",
                        "expectedUserType", "AGENTE"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.userType").value("AGENTE"));
    }

    @Test
    void unifiedLoginWithExpectedUserTypeAgenteRejectsClient() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of(
                        "email", "cliente@matrix.com",
                        "password", "senha123",
                        "expectedUserType", "AGENTE"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(
                        "Acesso negado. Este usuário não tem permissão para acessar esta aplicação."));
    }

    @Test
    void unifiedLoginWithExpectedUserTypeClienteRejectsAgent() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of(
                        "email", "agente@matrix.com",
                        "password", "senha123",
                        "expectedUserType", "CLIENTE"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(
                        "Acesso negado. Este usuário não tem permissão para acessar esta aplicação."));
    }

    @Test
    void unifiedLoginWithWrongPasswordStillReturnsGenericMessage() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of(
                        "email", "agente@matrix.com",
                        "password", "senha-errada",
                        "expectedUserType", "AGENTE"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("E-mail ou senha incorretos."));
    }
}
