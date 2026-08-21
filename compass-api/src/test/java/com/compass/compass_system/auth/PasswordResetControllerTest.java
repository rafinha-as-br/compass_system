package com.compass.compass_system.auth;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.entities.PasswordResetToken;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.repositories.PasswordResetTokenRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class PasswordResetControllerTest {

    private static final String GENERIC_FORGOT_PASSWORD_MESSAGE =
            "Se o e-mail informado estiver cadastrado, você receberá instruções para redefinir sua senha.";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AgentUserRepository agentUserRepository;

    @Autowired
    private ClientUserRepository clientUserRepository;

    @Autowired
    private PasswordResetTokenRepository passwordResetTokenRepository;

    @MockBean
    private JavaMailSender mailSender;

    private ClientUser client;
    private AgentUser agent;

    @BeforeEach
    void setUp() {
        passwordResetTokenRepository.deleteAll();
        agentUserRepository.deleteAll();
        clientUserRepository.deleteAll();

        agent = new AgentUser();
        agent.setName("Carlos Agente");
        agent.setEmail("agente@matrix.com");
        agent.setPassword(BCrypt.hashpw("senha123", BCrypt.gensalt()));
        agent = agentUserRepository.save(agent);

        client = new ClientUser();
        client.setName("Maria Cliente");
        client.setEmail("cliente@matrix.com");
        client.setPassword(BCrypt.hashpw("senha123", BCrypt.gensalt()));
        client = clientUserRepository.save(client);
    }

    @Test
    void forgotPasswordWithExistingClientEmailGeneratesTokenAndSendsEmail() throws Exception {
        mockMvc.perform(post("/api/auth/esqueci-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", client.getEmail()))))
                .andExpect(status().isOk())
                .andExpect(content().string(GENERIC_FORGOT_PASSWORD_MESSAGE));

        assertEquals(1, passwordResetTokenRepository.findAll().size());
        PasswordResetToken saved = passwordResetTokenRepository.findAll().get(0);
        assertEquals(client.getEmail(), saved.getEmail());
        assertFalse(saved.isUsed());

        verify(mailSender).send(any(SimpleMailMessage.class));
    }

    @Test
    void forgotPasswordWithUnknownEmailReturnsSameGenericMessageAndSendsNoEmail() throws Exception {
        mockMvc.perform(post("/api/auth/esqueci-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", "nao-existe@matrix.com"))))
                .andExpect(status().isOk())
                .andExpect(content().string(GENERIC_FORGOT_PASSWORD_MESSAGE));

        assertTrue(passwordResetTokenRepository.findAll().isEmpty());
        verify(mailSender, never()).send(any(SimpleMailMessage.class));
    }

    @Test
    void resetPasswordWithValidTokenUpdatesClientPasswordAndMarksTokenUsed() throws Exception {
        PasswordResetToken token = passwordResetTokenRepository.save(new PasswordResetToken(
                client.getEmail(), "valid-token", Instant.now().plus(30, ChronoUnit.MINUTES)));

        mockMvc.perform(post("/api/auth/redefinir-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("token", token.getToken(), "novaSenha", "novaSenha456"))))
                .andExpect(status().isOk())
                .andExpect(content().string("Senha redefinida com sucesso."));

        ClientUser updated = clientUserRepository.findById(client.getId()).orElseThrow();
        assertTrue(BCrypt.checkpw("novaSenha456", updated.getPassword()));

        PasswordResetToken usedToken = passwordResetTokenRepository.findByToken("valid-token").orElseThrow();
        assertTrue(usedToken.isUsed());
    }

    @Test
    void resetPasswordWithValidTokenUpdatesAgentPassword() throws Exception {
        PasswordResetToken token = passwordResetTokenRepository.save(new PasswordResetToken(
                agent.getEmail(), "agent-token", Instant.now().plus(30, ChronoUnit.MINUTES)));

        mockMvc.perform(post("/api/auth/redefinir-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("token", token.getToken(), "novaSenha", "outraSenha789"))))
                .andExpect(status().isOk());

        AgentUser updated = agentUserRepository.findById(agent.getId()).orElseThrow();
        assertTrue(BCrypt.checkpw("outraSenha789", updated.getPassword()));
    }

    @Test
    void resetPasswordWithExpiredTokenIsRejected() throws Exception {
        PasswordResetToken token = passwordResetTokenRepository.save(new PasswordResetToken(
                client.getEmail(), "expired-token", Instant.now().minus(1, ChronoUnit.MINUTES)));

        mockMvc.perform(post("/api/auth/redefinir-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("token", token.getToken(), "novaSenha", "novaSenha456"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Token inválido ou expirado."));
    }

    @Test
    void resetPasswordWithAlreadyUsedTokenIsRejected() throws Exception {
        PasswordResetToken token = new PasswordResetToken(
                client.getEmail(), "used-token", Instant.now().plus(30, ChronoUnit.MINUTES));
        token.setUsed(true);
        passwordResetTokenRepository.save(token);

        mockMvc.perform(post("/api/auth/redefinir-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("token", token.getToken(), "novaSenha", "novaSenha456"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Token inválido ou expirado."));
    }

    @Test
    void resetPasswordWithUnknownTokenIsRejected() throws Exception {
        mockMvc.perform(post("/api/auth/redefinir-senha")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("token", "token-inexistente", "novaSenha", "novaSenha456"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Token inválido ou expirado."));
    }
}
