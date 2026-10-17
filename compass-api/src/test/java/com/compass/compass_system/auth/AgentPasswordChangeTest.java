package com.compass.compass_system.auth;

import com.compass.compass_system.company.AgentFixtures;
import com.compass.compass_system.company.CompanyRepository;
import com.compass.compass_system.company.CompanyService;
import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.PasswordResetToken;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.PasswordResetTokenRepository;
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
import org.springframework.test.web.servlet.ResultActions;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Troca de senha obrigatória do agente convidado (CPS-196). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AgentPasswordChangeTest {

    private static final String TEMP_PASSWORD = "Temp1234";
    private static final String EMAIL = "convidado@pwd.com.br";

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private AgentUserRepository agentRepository;
    @Autowired private CompanyRepository companyRepository;
    @Autowired private CompanyService companyService;
    @Autowired private PasswordResetTokenRepository resetTokenRepository;

    @BeforeEach
    void setUp() {
        resetTokenRepository.deleteAll();
        agentRepository.deleteAll();

        AgentUser agent = AgentFixtures.saveOwner(agentRepository, companyRepository, "Convidado", EMAIL,
                BCrypt.hashpw(TEMP_PASSWORD, BCrypt.gensalt()));
        agent.setMustChangePassword(true);
        agentRepository.save(agent);
    }

    private ResultActions postJson(String path, Object body) throws Exception {
        return mockMvc.perform(post(path).contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private String login(String password) throws Exception {
        String body = postJson("/api/auth/login", Map.of("email", EMAIL, "password", password))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return "Bearer " + objectMapper.readTree(body).at("/data/token").asText();
    }

    private ResultActions change(String token, String current, String next) throws Exception {
        return mockMvc.perform(put("/api/agents/me/password").header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of("currentPassword", current, "newPassword", next))));
    }

    @Test
    void loginExposesTheFlag() throws Exception {
        postJson("/api/auth/login", Map.of("email", EMAIL, "password", TEMP_PASSWORD))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.mustChangePassword").value(true));
        postJson("/api/auth/login/agente", Map.of("email", EMAIL, "password", TEMP_PASSWORD))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mustChangePassword").value(true));
    }

    @Test
    void protectedRoutesAreBlockedUntilThePasswordIsChanged() throws Exception {
        String token = login(TEMP_PASSWORD);

        mockMvc.perform(get("/api/companies/me").header("Authorization", token))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error").value("PASSWORD_CHANGE_REQUIRED"));
        mockMvc.perform(get("/users/me").header("Authorization", token))
                .andExpect(status().isOk());
    }

    @Test
    void changingThePasswordUnblocksTheAgent() throws Exception {
        String token = login(TEMP_PASSWORD);

        change(token, TEMP_PASSWORD, "NovaSenha123").andExpect(status().isOk());

        assertFalse(agentRepository.findByEmail(EMAIL).orElseThrow().isMustChangePassword());
        mockMvc.perform(get("/api/companies/me").header("Authorization", token)).andExpect(status().isOk());
        login("NovaSenha123");
    }

    @Test
    void invalidChangesAreRefusedWithAClearMessage() throws Exception {
        String token = login(TEMP_PASSWORD);

        change(token, "errada-123", "NovaSenha123").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A senha atual está incorreta."));
        change(token, TEMP_PASSWORD, "curta").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A nova senha deve ter no mínimo 8 caracteres."));
        change(token, TEMP_PASSWORD, TEMP_PASSWORD).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A nova senha deve ser diferente da senha atual."));

        assertTrue(agentRepository.findByEmail(EMAIL).orElseThrow().isMustChangePassword());
    }

    @Test
    void passwordResetByEmailClearsTheFlag() throws Exception {
        resetTokenRepository.save(new PasswordResetToken(EMAIL, "tok-196", Instant.now().plus(30, ChronoUnit.MINUTES)));

        postJson("/api/auth/redefinir-senha", Map.of("token", "tok-196", "novaSenha", "OutraSenha1"))
                .andExpect(status().isOk());

        assertFalse(agentRepository.findByEmail(EMAIL).orElseThrow().isMustChangePassword());
    }

    @Test
    void invitedAgentsMustChangeThePasswordButFoundersDoNot() {
        AgentUser owner = agentRepository.findByEmail(EMAIL).orElseThrow();
        CompanyService.InvitedAgent invited = companyService.inviteAgent(owner.getCompany(), "Ana Paula");

        assertTrue(agentRepository.findById(invited.agent().getId()).orElseThrow().isMustChangePassword());
        assertFalse(AgentFixtures.saveOwner(agentRepository, companyRepository, "Fundador",
                "fundador@pwd.com.br", "hash").isMustChangePassword());
    }
}
