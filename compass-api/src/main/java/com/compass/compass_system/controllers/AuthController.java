package com.compass.compass_system.controllers;

import com.compass.compass_system.dto.LoginResponse;
import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.mindrot.jbcrypt.BCrypt;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private ClientUserRepository clientRepository;

    @Autowired
    private AgentUserRepository agentRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // Classe auxiliar simples para receber os dados da tela de login
    public static class LoginRequest {
        public String email;
        public String password;
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
}
