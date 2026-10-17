package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.exceptions.ForbiddenException;
import com.compass.compass_system.repositories.AgentUserRepository;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Troca de senha do próprio agente. É o único endpoint (além de GET /users/me)
 * que o JwtAuthenticationFilter deixa passar enquanto mustChangePassword está
 * ativo — o caminho precisa bater com JwtAuthenticationFilter.PASSWORD_CHANGE_PATH.
 */
@RestController
@RequestMapping("/api/agents/me/password")
public class AgentPasswordController {

    static final int MIN_PASSWORD_LENGTH = 8;

    private final AgentUserRepository agentRepository;

    public AgentPasswordController(AgentUserRepository agentRepository) {
        this.agentRepository = agentRepository;
    }

    public static class ChangePasswordRequest {
        public String currentPassword;
        public String newPassword;
    }

    // ─── PUT /api/agents/me/password ───────────────────────────────────────────
    // Exige a senha atual; a nova precisa ter no mínimo 8 caracteres e ser
    // diferente da atual (a temporária, no primeiro login). Limpa mustChangePassword.
    @PutMapping
    public ResponseEntity<Map<String, Object>> changePassword(@RequestBody ChangePasswordRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getAuthorities().stream().noneMatch(a -> "ROLE_AGENTE".equals(a.getAuthority()))) {
            throw new ForbiddenException("Apenas agentes podem trocar a senha por este endpoint.");
        }
        AgentUser agent = agentRepository.findByEmail(auth.getName())
                .orElseThrow(() -> new ForbiddenException("Agente não encontrado."));

        if (request.currentPassword == null || !BCrypt.checkpw(request.currentPassword, agent.getPassword())) {
            throw new BusinessException("A senha atual está incorreta.");
        }
        if (request.newPassword == null || request.newPassword.length() < MIN_PASSWORD_LENGTH) {
            throw new BusinessException("A nova senha deve ter no mínimo " + MIN_PASSWORD_LENGTH + " caracteres.");
        }
        if (request.newPassword.equals(request.currentPassword)) {
            throw new BusinessException("A nova senha deve ser diferente da senha atual.");
        }

        agent.setPassword(BCrypt.hashpw(request.newPassword, BCrypt.gensalt()));
        agent.setMustChangePassword(false);
        agentRepository.save(agent);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", null);
        response.put("message", "Senha alterada com sucesso.");
        return ResponseEntity.ok(response);
    }
}
