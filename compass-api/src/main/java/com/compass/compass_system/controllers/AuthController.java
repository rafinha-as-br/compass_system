package com.compass.compass_system.controllers;

import com.compass.compass_system.dto.LoginResponse;
import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.entities.PasswordResetToken;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.repositories.PasswordResetTokenRepository;
import com.compass.compass_system.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.*;
import org.mindrot.jbcrypt.BCrypt;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private ClientUserRepository clientRepository;

    @Autowired
    private AgentUserRepository agentRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordResetTokenRepository passwordResetTokenRepository;

    @Autowired
    private JavaMailSender mailSender;

    @Value("${app.password-reset.token-expiration-minutes:30}")
    private long tokenExpirationMinutes;

    // Classe auxiliar simples para receber os dados da tela de login
    public static class LoginRequest {
        public String email;
        public String password;
        // Opcional: quando informado ("AGENTE" ou "CLIENTE"), o login unificado
        // só é aceito se o tipo do usuário encontrado bater com o esperado.
        // Usado pelo Travel Matrix (só AGENTE); o RouteCraft não envia esse
        // campo e continua aceitando qualquer tipo, como antes.
        public String expectedUserType;
    }

    public static class ForgotPasswordRequest {
        public String email;
    }

    public static class ResetPasswordRequest {
        public String token;
        public String novaSenha;
    }

    // ==================== CADASTRO ====================

    // Rota para Cadastrar o Cliente
    @PostMapping("/cadastrar/cliente")
    public ResponseEntity<String> registerClient(@RequestBody ClientUser newClient) {
        
        // Verifica se o e-mail já existe no banco antes de salvar
        Optional<ClientUser> existingClient = clientRepository.findByEmail(newClient.getEmail());
        if (existingClient.isPresent()) {
            throw new BusinessException("Este e-mail já está cadastrado.");
        }

        // Criptografar a senha antes de salvar
        if (newClient.getPassword() != null && !newClient.getPassword().isEmpty()) {
            String hashedPassword = BCrypt.hashpw(newClient.getPassword(), BCrypt.gensalt());
            newClient.setPassword(hashedPassword);
        }

        // Salva o cliente no banco de dados 
        clientRepository.save(newClient);
        
        return ResponseEntity.ok("Cliente cadastrado com sucesso no Compass System!");
    }

    // Rota para Cadastrar o Agente
    @PostMapping("/cadastrar/agente")
    public ResponseEntity<String> registerAgent(@RequestBody AgentUser newAgent) {
        
        // Verifica se o e-mail já existe no banco antes de salvar
        Optional<AgentUser> existingAgent = agentRepository.findByEmail(newAgent.getEmail());
        if (existingAgent.isPresent()) {
            throw new BusinessException("Este e-mail já está cadastrado.");
        }

        // Criptografar a senha antes de salvar
        if (newAgent.getPassword() != null && !newAgent.getPassword().isEmpty()) {
            String hashedPassword = BCrypt.hashpw(newAgent.getPassword(), BCrypt.gensalt());
            newAgent.setPassword(hashedPassword);
        }

        // Salva o agente no banco de dados 
        agentRepository.save(newAgent);
        
        return ResponseEntity.ok("Agente cadastrado com sucesso no Compass System!");
    }

    // ==================== LOGIN ====================

    // Rota para o Login do Cliente (retorna JWT)
    @PostMapping("/login/cliente")
    public ResponseEntity<LoginResponse> loginClient(@RequestBody LoginRequest login) {
        
        // Busca o cliente no banco pelo email
        Optional<ClientUser> clientOpt = clientRepository.findByEmail(login.email);
        
        // Verifica se o cliente existe e se a senha digitada bate com a do banco
        if (clientOpt.isPresent() && BCrypt.checkpw(login.password, clientOpt.get().getPassword())) {
            ClientUser client = clientOpt.get();
            String token = jwtUtil.generateToken(client.getEmail(), "CLIENTE", client.getId());
            
            LoginResponse response = new LoginResponse(
                token, client.getId(), client.getName(), client.getEmail(), "CLIENTE"
            );
            return ResponseEntity.ok(response);
        }
        
        // Se algo estiver errado barra o acesso 
        throw new BusinessException("E-mail ou senha incorretos.");
    }

    // Rota para o Login do Agente (retorna JWT)
    @PostMapping("/login/agente")
    public ResponseEntity<LoginResponse> loginAgent(@RequestBody LoginRequest login) {
        
        // Busca o agente no banco pelo email
        Optional<AgentUser> agentOpt = agentRepository.findByEmail(login.email);
        
        // Verifica se o agente existe e se a senha digitada bate com a do banco
        if (agentOpt.isPresent() && BCrypt.checkpw(login.password, agentOpt.get().getPassword())) {
            AgentUser agent = agentOpt.get();
            String token = jwtUtil.generateToken(agent.getEmail(), "AGENTE", agent.getId());
            
            LoginResponse response = new LoginResponse(
                token, agent.getId(), agent.getName(), agent.getEmail(), "AGENTE"
            );
            return ResponseEntity.ok(response);
        }
        
        // Se algo estiver errado barra o acesso 
        throw new BusinessException("E-mail ou senha incorretos.");
    }

    // ==================== LOGIN UNIFICADO ====================

    // Rota unificada de login: tenta autenticar como agente, depois como cliente.
    // Retorna formato compatível com o frontend Travel Matrix.
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> loginUnified(@RequestBody LoginRequest login) {

        // Tenta como agente primeiro
        Optional<AgentUser> agentOpt = agentRepository.findByEmail(login.email);
        if (agentOpt.isPresent() && BCrypt.checkpw(login.password, agentOpt.get().getPassword())) {
            if (login.expectedUserType != null && !"AGENTE".equals(login.expectedUserType)) {
                throw new BusinessException("Acesso negado. Este usuário não tem permissão para acessar esta aplicação.");
            }
            AgentUser agent = agentOpt.get();
            String token = jwtUtil.generateToken(agent.getEmail(), "AGENTE", agent.getId());

            Map<String, Object> data = new java.util.LinkedHashMap<>();
            data.put("token", token);
            data.put("userId", String.valueOf(agent.getId()));
            data.put("name", agent.getName());
            data.put("email", agent.getEmail());
            data.put("userType", "AGENTE");

            Map<String, Object> response = new java.util.LinkedHashMap<>();
            response.put("status", "success");
            response.put("data", data);
            response.put("message", null);
            return ResponseEntity.ok(response);
        }

        // Tenta como cliente
        Optional<ClientUser> clientOpt = clientRepository.findByEmail(login.email);
        if (clientOpt.isPresent() && BCrypt.checkpw(login.password, clientOpt.get().getPassword())) {
            if (login.expectedUserType != null && !"CLIENTE".equals(login.expectedUserType)) {
                throw new BusinessException("Acesso negado. Este usuário não tem permissão para acessar esta aplicação.");
            }
            ClientUser client = clientOpt.get();
            String token = jwtUtil.generateToken(client.getEmail(), "CLIENTE", client.getId());

            Map<String, Object> data = new java.util.LinkedHashMap<>();
            data.put("token", token);
            data.put("userId", String.valueOf(client.getId()));
            data.put("name", client.getName());
            data.put("email", client.getEmail());
            data.put("userType", "CLIENTE");

            Map<String, Object> response = new java.util.LinkedHashMap<>();
            response.put("status", "success");
            response.put("data", data);
            response.put("message", null);
            return ResponseEntity.ok(response);
        }

        throw new BusinessException("E-mail ou senha incorretos.");
    }

    // ==================== RECUPERAÇÃO DE SENHA ====================

    // Rota pública para solicitar a recuperação de senha. Sempre responde com
    // sucesso genérico, exista ou não o e-mail informado, para não vazar quais
    // e-mails estão cadastrados.
    @PostMapping("/esqueci-senha")
    public ResponseEntity<String> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        boolean emailExists = clientRepository.findByEmail(request.email).isPresent()
                || agentRepository.findByEmail(request.email).isPresent();

        if (emailExists) {
            String token = UUID.randomUUID().toString();
            Instant expiresAt = Instant.now().plus(tokenExpirationMinutes, ChronoUnit.MINUTES);
            passwordResetTokenRepository.save(new PasswordResetToken(request.email, token, expiresAt));
            sendPasswordResetEmail(request.email, token);
        }

        return ResponseEntity.ok(
                "Se o e-mail informado estiver cadastrado, você receberá instruções para redefinir sua senha.");
    }

    // Rota pública para efetivar a redefinição de senha a partir do token
    // recebido por e-mail.
    @PostMapping("/redefinir-senha")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.token)
                .orElseThrow(() -> new BusinessException("Token inválido ou expirado."));

        if (resetToken.isUsed() || resetToken.getExpiresAt().isBefore(Instant.now())) {
            throw new BusinessException("Token inválido ou expirado.");
        }

        String hashedPassword = BCrypt.hashpw(request.novaSenha, BCrypt.gensalt());

        Optional<ClientUser> clientOpt = clientRepository.findByEmail(resetToken.getEmail());
        if (clientOpt.isPresent()) {
            ClientUser client = clientOpt.get();
            client.setPassword(hashedPassword);
            clientRepository.save(client);
        } else {
            AgentUser agent = agentRepository.findByEmail(resetToken.getEmail())
                    .orElseThrow(() -> new BusinessException("Token inválido ou expirado."));
            agent.setPassword(hashedPassword);
            agentRepository.save(agent);
        }

        resetToken.setUsed(true);
        passwordResetTokenRepository.save(resetToken);

        return ResponseEntity.ok("Senha redefinida com sucesso.");
    }

    // Envia o e-mail com o token de redefinição. Falha no envio não deve vazar
    // para a resposta do endpoint (que já respondeu sucesso genérico) nem
    // impedir que o token gerado continue válido.
    private void sendPasswordResetEmail(String email, String token) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("Recuperação de senha - Compass System");
            message.setText(
                    "Você solicitou a redefinição de senha no Compass System.\n\n"
                    + "Use o código abaixo no aplicativo para criar uma nova senha:\n\n"
                    + token
                    + "\n\nEste código expira em " + tokenExpirationMinutes + " minutos. "
                    + "Se você não fez essa solicitação, ignore este e-mail.");
            mailSender.send(message);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
