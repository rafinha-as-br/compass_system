package com.compass.compass_system.company;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.exceptions.ForbiddenException;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.security.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Rotas do módulo company, sempre no contexto da empresa do agente autenticado
 * ("/me"). Consulta (empresa e lista de agentes) é liberada para OWNER e
 * MEMBER; gestão de agentes (convite, remoção, papel) é só OWNER.
 * Respostas no envelope {status, data, message} usado pelo Travel Matrix.
 */
@RestController
@RequestMapping("/api/companies/me")
public class CompanyController {

    private final CompanyService companyService;
    private final AgentUserRepository agentRepository;
    private final JwtUtil jwtUtil;

    public CompanyController(CompanyService companyService,
                             AgentUserRepository agentRepository,
                             JwtUtil jwtUtil) {
        this.companyService = companyService;
        this.agentRepository = agentRepository;
        this.jwtUtil = jwtUtil;
    }

    public static class InviteAgentRequest {
        public String name;
    }

    public static class ChangeRoleRequest {
        public String role;
    }

    // ─── GET /api/companies/me ─────────────────────────────────────────────────
    // Dados da empresa + plano atual + papel do agente logado (OWNER, MEMBER).
    @GetMapping
    public ResponseEntity<Map<String, Object>> getMyCompany(
            @RequestHeader("Authorization") String authHeader) {
        AgentUser agent = currentAgent(authHeader);
        Company company = companyService.requireCompany(agent);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", String.valueOf(company.getId()));
        data.put("name", company.getName());
        data.put("cnpj", company.getCnpj());
        data.put("domain", company.getDomain());
        data.put("plan", company.getPlan().name());

        Map<String, Object> currentAgent = new LinkedHashMap<>();
        currentAgent.put("id", String.valueOf(agent.getId()));
        currentAgent.put("role", agent.getRole() != null ? agent.getRole().name() : null);
        data.put("currentAgent", currentAgent);

        return ResponseEntity.ok(envelope(data));
    }

    // ─── GET /api/companies/me/agents ──────────────────────────────────────────
    // Lista os agentes da empresa (OWNER e MEMBER — decisão da CPS-162: MEMBER
    // precisa da lista para o Painel da Empresa; o DTO não tem dado sensível de
    // gestão, então o payload é o mesmo para os dois papéis).
    @GetMapping("/agents")
    public ResponseEntity<Map<String, Object>> listAgents(
            @RequestHeader("Authorization") String authHeader) {
        AgentUser agent = currentAgent(authHeader);
        Company company = companyService.requireCompany(agent);

        List<Map<String, Object>> agents = new ArrayList<>();
        for (AgentUser member : companyService.listAgents(company)) {
            agents.add(mapAgent(member));
        }
        return ResponseEntity.ok(envelope(agents));
    }

    // ─── POST /api/companies/me/agents/invite ──────────────────────────────────
    // Cria um MEMBER com login gerado (localPart@domain) e senha temporária,
    // devolvida uma única vez (MVP sem e-mail).
    @PostMapping("/agents/invite")
    public ResponseEntity<Map<String, Object>> inviteAgent(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody InviteAgentRequest request) {
        AgentUser agent = currentAgent(authHeader);
        Company company = companyService.requireCompany(agent);
        companyService.assertOwner(agent);

        CompanyService.InvitedAgent invited = companyService.inviteAgent(company, request.name);

        Map<String, Object> data = mapAgent(invited.agent());
        data.put("temporaryPassword", invited.temporaryPassword());
        return ResponseEntity.ok(envelope(data));
    }

    // ─── DELETE /api/companies/me/agents/{agentId} ─────────────────────────────
    @DeleteMapping("/agents/{agentId}")
    public ResponseEntity<Map<String, Object>> removeAgent(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable Long agentId) {
        AgentUser agent = currentAgent(authHeader);
        Company company = companyService.requireCompany(agent);
        companyService.assertOwner(agent);

        companyService.removeAgent(company, agentId);
        return ResponseEntity.ok(envelope(null));
    }

    // ─── PUT /api/companies/me/agents/{agentId}/role ───────────────────────────
    @PutMapping("/agents/{agentId}/role")
    public ResponseEntity<Map<String, Object>> changeRole(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable Long agentId,
            @RequestBody ChangeRoleRequest request) {
        AgentUser agent = currentAgent(authHeader);
        Company company = companyService.requireCompany(agent);
        companyService.assertOwner(agent);

        AgentUser updated = companyService.changeRole(company, agentId, parseRole(request.role));
        return ResponseEntity.ok(envelope(mapAgent(updated)));
    }

    // ─── helpers ───────────────────────────────────────────────────────────────

    private AgentUser currentAgent(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        if (!"AGENTE".equals(jwtUtil.getUserTypeFromToken(token))) {
            throw new ForbiddenException("Apenas agentes acessam o módulo de empresa.");
        }
        return agentRepository.findByEmail(jwtUtil.getEmailFromToken(token))
                .orElseThrow(() -> new ForbiddenException("Agente não encontrado."));
    }

    private static AgentRole parseRole(String raw) {
        if (raw == null) {
            throw new BusinessException("Papel inválido. Use OWNER ou MEMBER.");
        }
        try {
            return AgentRole.valueOf(raw.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new BusinessException("Papel inválido. Use OWNER ou MEMBER.");
        }
    }

    private static Map<String, Object> mapAgent(AgentUser agent) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", String.valueOf(agent.getId()));
        map.put("name", agent.getName());
        map.put("login", agent.getEmail());
        map.put("role", agent.getRole() != null ? agent.getRole().name() : null);
        // "na empresa desde" — null para agentes anteriores ao módulo company.
        map.put("memberSince", agent.getCreatedAt() != null ? agent.getCreatedAt().toString() : null);
        return map;
    }

    private static Map<String, Object> envelope(Object data) {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");
        response.put("data", data);
        response.put("message", null);
        return response;
    }
}
