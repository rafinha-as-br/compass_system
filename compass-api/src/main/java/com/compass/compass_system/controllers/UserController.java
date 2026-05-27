package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.exceptions.ResourceNotFoundException;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.security.JwtUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * CRUD completo de ClientUser (clientes de viagem).
 *
 * Rotas protegidas por JWT — apenas agentes autenticados podem acessar.
 *
 * GET    /api/users            → lista todos os clientes
 * GET    /api/users/{id}       → busca um cliente por ID
 * POST   /api/users            → cria um novo cliente (agente cria pelo painel)
 * PUT    /api/users/{id}       → atualiza dados de um cliente
 * DELETE /api/users/{id}       → remove um cliente
 * GET    /api/users/me         → retorna o usuário autenticado pelo token (agente ou cliente)
 */
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private ClientUserRepository clientRepository;

    // MUDANÇA PARA INTEGRAÇÃO: adicionado para suportar agentes no endpoint /me
    @Autowired
    private AgentUserRepository agentRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // ─── GET /api/users ────────────────────────────────────────────────────────
    // Retorna todos os clientes. Chamado por CompassService.getAllUsers().
    @GetMapping
    public ResponseEntity<List<ClientUser>> getAllUsers() {
        List<ClientUser> users = clientRepository.findAll();
        // Não retorna senhas: limpa o campo antes de serializar
        users.forEach(u -> u.setPassword(null));
        return ResponseEntity.ok(users);
    }

    // ─── GET /api/users/me ─────────────────────────────────────────────────────
    // Retorna o usuário autenticado com base no email extraído do JWT.
    // Chamado por CompassService.getUser(token).
    // MUDANÇA PARA INTEGRAÇÃO: agora busca em ClientUser E AgentUser,
    // pois o agente logado estava causando 404 (email só existe na tabela de agentes).
    // NOTA: deve vir ANTES de /{id} para o Spring não interpretar "me" como um Long.
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getMe(
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        String email = jwtUtil.getEmailFromToken(token);

        // Tenta primeiro na tabela de clientes
        Optional<ClientUser> clientOpt = clientRepository.findByEmail(email);
        if (clientOpt.isPresent()) {
            ClientUser user = clientOpt.get();
            user.setPassword(null);
            Map<String, Object> response = new HashMap<>();
            response.put("id", user.getId());
            response.put("name", user.getName());
            response.put("email", user.getEmail());
            response.put("cpf", user.getCpf());
            response.put("age", user.getAge());
            response.put("gender", user.getGender());
            response.put("phone", user.getPhone());
            response.put("userType", "client");
            return ResponseEntity.ok(response);
        }

        // Se não for cliente, tenta na tabela de agentes
        AgentUser agent = agentRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado."));
        agent.setPassword(null);
        Map<String, Object> response = new HashMap<>();
        response.put("id", agent.getId());
        response.put("name", agent.getName());
        response.put("email", agent.getEmail());
        response.put("cpf", agent.getCpf());
        response.put("age", agent.getAge());
        response.put("gender", agent.getGender());
        response.put("phone", agent.getPhone());
        response.put("cnpj", agent.getCnpj());
        response.put("userType", "travel_agent");
        return ResponseEntity.ok(response);
    }

    // ─── GET /api/users/{id} ───────────────────────────────────────────────────
    // Busca um cliente por ID.
    @GetMapping("/{id}")
    public ResponseEntity<ClientUser> getUser(@PathVariable Long id) {
        ClientUser user = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado."));
        user.setPassword(null);
        return ResponseEntity.ok(user);
    }

    // ─── POST /api/users ───────────────────────────────────────────────────────
    // Cria um novo cliente. Agente cria cliente pelo painel do Travel Matrix.
    // Chamado por CompassService.createUser(token, userData).
    @PostMapping
    public ResponseEntity<ClientUser> createUser(@RequestBody ClientUser newClient) {
        Optional<ClientUser> existing = clientRepository.findByEmail(newClient.getEmail());
        if (existing.isPresent()) {
            throw new BusinessException("Este e-mail já está cadastrado.");
        }

        if (newClient.getPassword() != null && !newClient.getPassword().isEmpty()) {
            newClient.setPassword(BCrypt.hashpw(newClient.getPassword(), BCrypt.gensalt()));
        }

        ClientUser saved = clientRepository.save(newClient);
        saved.setPassword(null);
        return ResponseEntity.ok(saved);
    }

    // ─── PUT /api/users/{id} ───────────────────────────────────────────────────
    // Atualiza dados de um cliente existente.
    // Chamado por CompassService.updateUser(token, userData).
    // Se uma nova senha for enviada, ela é re-criptografada.
    @PutMapping("/{id}")
    public ResponseEntity<ClientUser> updateUser(
            @PathVariable Long id,
            @RequestBody ClientUser incoming) {

        ClientUser existing = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado."));

        // Atualiza apenas os campos não-nulos recebidos
        if (incoming.getName() != null)   existing.setName(incoming.getName());
        if (incoming.getCpf() != null)    existing.setCpf(incoming.getCpf());
        if (incoming.getAge() != null)    existing.setAge(incoming.getAge());
        if (incoming.getGender() != null) existing.setGender(incoming.getGender());
        if (incoming.getPhone() != null)  existing.setPhone(incoming.getPhone());
        if (incoming.getEmail() != null)  existing.setEmail(incoming.getEmail());

        // Re-criptografa a senha somente se uma nova for enviada
        if (incoming.getPassword() != null && !incoming.getPassword().isEmpty()) {
            existing.setPassword(BCrypt.hashpw(incoming.getPassword(), BCrypt.gensalt()));
        }

        ClientUser saved = clientRepository.save(existing);
        saved.setPassword(null);
        return ResponseEntity.ok(saved);
    }

    // ─── DELETE /api/users/{id} ────────────────────────────────────────────────
    // Remove um cliente por ID. Agente only.
    // Chamado por CompassService.deleteUser(token, userId).
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (!clientRepository.existsById(id)) {
            throw new ResourceNotFoundException("Usuário não encontrado.");
        }
        clientRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
