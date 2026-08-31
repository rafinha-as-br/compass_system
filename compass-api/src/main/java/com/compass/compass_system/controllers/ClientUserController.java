package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.security.JwtUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.*;

/**
 * Controller para operações CRUD de clientes (users).
 * Utilizado pelo Travel Matrix para gerenciar clientes do sistema.
 */
@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class ClientUserController {

    @Autowired
    private ClientUserRepository clientRepository;

    @Autowired
    private AgentUserRepository agentRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // ─── GET /users/me ─────────────────────────────────────────────────────────
    // Returns the authenticated user's profile (agent or client) based on the JWT.
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getAuthenticatedUser(
            @RequestHeader("Authorization") String authHeader) {

        String token = authHeader.replace("Bearer ", "");
        String email = jwtUtil.getEmailFromToken(token);
        String userType = jwtUtil.getUserTypeFromToken(token);

        if ("AGENTE".equals(userType)) {
            Optional<AgentUser> agentOpt = agentRepository.findByEmail(email);
            if (agentOpt.isPresent()) {
                AgentUser agent = agentOpt.get();
                Map<String, Object> response = new LinkedHashMap<>();
                response.put("id", String.valueOf(agent.getId()));
                response.put("name", agent.getName());
                response.put("email", agent.getEmail());
                response.put("cpf", agent.getCpf());
                response.put("cnpj", agent.getCnpj());
                response.put("phoneNumber", agent.getPhone());
                response.put("userType", "AGENTE");
                return ResponseEntity.ok(response);
            }
        } else {
            Optional<ClientUser> clientOpt = clientRepository.findByEmail(email);
            if (clientOpt.isPresent()) {
                return ResponseEntity.ok(mapClientToResponse(clientOpt.get()));
            }
        }

        return ResponseEntity.notFound().build();
    }

    // ─── GET /users ────────────────────────────────────────────────────────────
    // Returns all client users.
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllUsers() {
        List<ClientUser> clients = clientRepository.findAll();
        List<Map<String, Object>> userList = new ArrayList<>();
        for (ClientUser client : clients) {
            userList.add(mapClientToResponse(client));
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", userList);
        response.put("message", null);
        return ResponseEntity.ok(response);
    }

    // ─── GET /users/{id} ───────────────────────────────────────────────────────
    // Returns a client user by ID.
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getUserById(@PathVariable Long id) {
        Optional<ClientUser> opt = clientRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", mapClientToResponse(opt.get()));
        response.put("message", null);
        return ResponseEntity.ok(response);
    }

    // ─── POST /users ───────────────────────────────────────────────────────────
    // Creates a new client user (agent-initiated).
    @PostMapping
    public ResponseEntity<Map<String, Object>> createUser(@RequestBody Map<String, Object> body) {
        ClientUser client = new ClientUser();
        client.setName((String) body.get("name"));
        client.setCpf((String) body.get("cpf"));
        client.setGender((String) body.getOrDefault("sex", "M"));
        client.setPhone((String) body.getOrDefault("phoneNumber", ""));
        client.setEmail((String) body.get("email"));

        // Default password for agent-created users
        String rawPassword = (String) body.getOrDefault("password", "compass123");
        client.setPassword(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));
        client.setIsActive(true);

        ClientUser saved = clientRepository.save(client);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", mapClientToResponse(saved));
        response.put("message", null);
        return ResponseEntity.ok(response);
    }

    // ─── PUT /users/{id} ───────────────────────────────────────────────────────
    // Updates a client user's data.
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {

        Optional<ClientUser> opt = clientRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ClientUser client = opt.get();
        if (body.containsKey("name")) client.setName((String) body.get("name"));
        if (body.containsKey("cpf")) client.setCpf((String) body.get("cpf"));
        if (body.containsKey("sex")) client.setGender((String) body.get("sex"));
        if (body.containsKey("phoneNumber")) client.setPhone((String) body.get("phoneNumber"));
        if (body.containsKey("email")) client.setEmail((String) body.get("email"));

        ClientUser saved = clientRepository.save(client);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", mapClientToResponse(saved));
        response.put("message", null);
        return ResponseEntity.ok(response);
    }

    // ─── POST /users/{id}/deactivate ───────────────────────────────────────────
    // Deactivates a client user.
    @PostMapping("/{id}/deactivate")
    public ResponseEntity<Map<String, Object>> deactivateUser(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {

        Optional<ClientUser> opt = clientRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ClientUser client = opt.get();
        client.setIsActive(false);
        client.setDeactivationReason((String) body.getOrDefault("reason", ""));
        clientRepository.save(client);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", null);
        response.put("message", "User deactivated successfully.");
        return ResponseEntity.ok(response);
    }

    // ─── POST /users/{id}/reset-password ───────────────────────────────────────
    // Resets a client's password to a default value.
    @PostMapping("/{id}/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@PathVariable Long id) {
        Optional<ClientUser> opt = clientRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ClientUser client = opt.get();
        client.setPassword(BCrypt.hashpw("compass123", BCrypt.gensalt()));
        clientRepository.save(client);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", null);
        response.put("message", "Password reset successfully.");
        return ResponseEntity.ok(response);
    }

    // ─── POST /users/{id}/force-logout ─────────────────────────────────────────
    // Marca o instante atual como "sessão invalidada" para o cliente: qualquer
    // token JWT emitido antes disso passa a ser rejeitado pelo
    // JwtAuthenticationFilter, mesmo sem ter expirado naturalmente.
    @PostMapping("/{id}/force-logout")
    public ResponseEntity<Map<String, Object>> forceLogout(@PathVariable Long id) {
        Optional<ClientUser> clientOpt = clientRepository.findById(id);
        if (clientOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ClientUser client = clientOpt.get();
        client.setSessionInvalidatedAt(Instant.now());
        clientRepository.save(client);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", null);
        response.put("message", "Logout forced successfully.");
        return ResponseEntity.ok(response);
    }

    // ─── Helper: Map entity to frontend-compatible response ────────────────────
    private Map<String, Object> mapClientToResponse(ClientUser client) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", String.valueOf(client.getId()));
        map.put("name", client.getName());
        map.put("cpf", client.getCpf());
        map.put("sex", client.getGender());
        map.put("phoneNumber", client.getPhone());
        map.put("email", client.getEmail());
        map.put("isActive", client.getIsActive());

        // Status object expected by frontend
        Map<String, Object> statusObj = new LinkedHashMap<>();
        Map<String, Object> innerStatus = new LinkedHashMap<>();
        innerStatus.put("type", client.getIsActive() ? "active" : "disabled");
        innerStatus.put("reason", client.getDeactivationReason());
        statusObj.put("status", innerStatus);
        statusObj.put("last_login", null);
        map.put("status", statusObj);

        return map;
    }
}
