package com.compass.compass_system.company;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.fasterxml.jackson.databind.JsonNode;
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

import java.util.LinkedHashMap;
import java.util.Map;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.emptyString;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CompanyControllerTest {

    private static final String PASSWORD = "senha123";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AgentUserRepository agentUserRepository;

    @Autowired
    private CompanyRepository companyRepository;

    private Company aurora;
    private Long ownerId;
    private Long memberId;
    private String ownerToken;
    private String memberToken;

    @BeforeEach
    void setUp() throws Exception {
        agentUserRepository.deleteAll();
        companyRepository.deleteAll();

        aurora = saveCompany("Aurora Viagens", "aurora.com.br", PlanType.PRO);
        ownerId = saveAgent("Carla Owner", "carla.owner@aurora.com.br", aurora, AgentRole.OWNER).getId();
        memberId = saveAgent("Bruno Member", "bruno.member@aurora.com.br", aurora, AgentRole.MEMBER).getId();

        ownerToken = login("carla.owner@aurora.com.br", PASSWORD);
        memberToken = login("bruno.member@aurora.com.br", PASSWORD);
    }

    // ─── GET /me ───────────────────────────────────────────────────────────────

    @Test
    void ownerSeesCompanyPlanAndOwnRole() throws Exception {
        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(ownerToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.name").value("Aurora Viagens"))
                .andExpect(jsonPath("$.data.domain").value("aurora.com.br"))
                .andExpect(jsonPath("$.data.plan").value("PRO"))
                .andExpect(jsonPath("$.data.currentAgent.id").value(String.valueOf(ownerId)))
                .andExpect(jsonPath("$.data.currentAgent.role").value("OWNER"));
    }

    @Test
    void memberSeesCompanyAndAgentList() throws Exception {
        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(memberToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.currentAgent.role").value("MEMBER"));

        mockMvc.perform(get("/api/companies/me/agents").header("Authorization", bearer(memberToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(2)))
                .andExpect(jsonPath("$.data[0].name").value("Bruno Member"))
                .andExpect(jsonPath("$.data[0].login").value("bruno.member@aurora.com.br"))
                .andExpect(jsonPath("$.data[0].role").value("MEMBER"))
                .andExpect(jsonPath("$.data[0].memberSince", not(emptyString())))
                .andExpect(jsonPath("$.data[1].role").value("OWNER"));
    }

    @Test
    void agentWithoutCompanyGetsNotFound() throws Exception {
        saveAgent("Solo Agent", "solo@matrix.com", null, null);
        String soloToken = login("solo@matrix.com", PASSWORD);

        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(soloToken)))
                .andExpect(status().isNotFound());
        mockMvc.perform(get("/api/companies/me/agents").header("Authorization", bearer(soloToken)))
                .andExpect(status().isNotFound());
    }

    @Test
    void clientTokenIsRejected() throws Exception {
        // Não há cliente cadastrado; um token de outro tipo não chega ao módulo.
        mockMvc.perform(get("/api/companies/me"))
                .andExpect(status().isForbidden());
    }

    // ─── POST /me/agents/invite ────────────────────────────────────────────────

    @Test
    void inviteGeneratesLoginFromNameAndTemporaryPasswordThatWorks() throws Exception {
        String body = mockMvc.perform(post("/api/companies/me/agents/invite")
                        .header("Authorization", bearer(ownerToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Ana Paula Ribeiro\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.login").value("ana.paula.ribeiro@aurora.com.br"))
                .andExpect(jsonPath("$.data.role").value("MEMBER"))
                .andExpect(jsonPath("$.data.memberSince", not(emptyString())))
                .andExpect(jsonPath("$.data.temporaryPassword", not(emptyString())))
                .andReturn().getResponse().getContentAsString();

        String temporaryPassword = objectMapper.readTree(body).at("/data/temporaryPassword").asText();
        assertEquals(10, temporaryPassword.length());

        // A senha temporária é uma credencial real: o convidado consegue logar.
        String invitedToken = login("ana.paula.ribeiro@aurora.com.br", temporaryPassword);
        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(invitedToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.currentAgent.role").value("MEMBER"));
    }

    @Test
    void inviteDisambiguatesCollidingLocalPartWithNumericSuffix() throws Exception {
        invite("Ana Paula Ribeiro").andExpect(jsonPath("$.data.login").value("ana.paula.ribeiro@aurora.com.br"));
        invite("Ana Paula Ribeiro").andExpect(jsonPath("$.data.login").value("ana.paula.ribeiro2@aurora.com.br"));
        invite("Ana Paula Ribeiro").andExpect(jsonPath("$.data.login").value("ana.paula.ribeiro3@aurora.com.br"));
    }

    @Test
    void inviteRejectsBlankName() throws Exception {
        invite("   ").andExpect(status().isBadRequest());
    }

    @Test
    void memberCannotInvite() throws Exception {
        mockMvc.perform(post("/api/companies/me/agents/invite")
                        .header("Authorization", bearer(memberToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Alguém\"}"))
                .andExpect(status().isForbidden());
    }

    // ─── DELETE /me/agents/{id} ────────────────────────────────────────────────

    @Test
    void ownerRemovesMemberAndTheirTokenStopsWorking() throws Exception {
        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(memberToken)))
                .andExpect(status().isOk());

        mockMvc.perform(delete("/api/companies/me/agents/" + memberId)
                        .header("Authorization", bearer(ownerToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"));

        assertTrue(agentUserRepository.findById(memberId).isEmpty());

        // Token stateless ainda válido, mas o agente já não existe → acesso invalidado.
        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(memberToken)))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/companies/me/agents").header("Authorization", bearer(ownerToken)))
                .andExpect(jsonPath("$.data", hasSize(1)));
    }

    @Test
    void soleOwnerCannotRemoveSelf() throws Exception {
        mockMvc.perform(delete("/api/companies/me/agents/" + ownerId)
                        .header("Authorization", bearer(ownerToken)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Você é o único OWNER da empresa — promova outro agente antes."));

        assertTrue(agentUserRepository.findById(ownerId).isPresent());
    }

    @Test
    void memberCannotRemoveAgents() throws Exception {
        mockMvc.perform(delete("/api/companies/me/agents/" + ownerId)
                        .header("Authorization", bearer(memberToken)))
                .andExpect(status().isForbidden());
    }

    @Test
    void cannotRemoveAgentFromAnotherCompany() throws Exception {
        Company other = saveCompany("Outra Agência", "outra.com.br", PlanType.FREE);
        Long outsiderId = saveAgent("Outsider", "outsider@outra.com.br", other, AgentRole.OWNER).getId();

        mockMvc.perform(delete("/api/companies/me/agents/" + outsiderId)
                        .header("Authorization", bearer(ownerToken)))
                .andExpect(status().isNotFound());

        assertTrue(agentUserRepository.findById(outsiderId).isPresent());
    }

    // ─── PUT /me/agents/{id}/role ──────────────────────────────────────────────

    @Test
    void soleOwnerCannotDemoteSelf() throws Exception {
        changeRole(ownerToken, ownerId, "MEMBER").andExpect(status().isBadRequest());
        assertEquals(AgentRole.OWNER, agentUserRepository.findById(ownerId).orElseThrow().getRole());
    }

    @Test
    void promotingAMemberAllowsDemotingTheOriginalOwner() throws Exception {
        changeRole(ownerToken, memberId, "OWNER")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.role").value("OWNER"));

        changeRole(ownerToken, ownerId, "MEMBER")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.role").value("MEMBER"));

        // Quem foi rebaixado perde as rotas de gestão.
        changeRole(ownerToken, memberId, "MEMBER").andExpect(status().isForbidden());
    }

    @Test
    void changingToTheSameRoleIsANoOp() throws Exception {
        changeRole(ownerToken, memberId, "member")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.role").value("MEMBER"));
    }

    @Test
    void invalidRoleIsRejected() throws Exception {
        changeRole(ownerToken, memberId, "ADMIN").andExpect(status().isBadRequest());
    }

    @Test
    void memberCannotChangeRoles() throws Exception {
        changeRole(memberToken, memberId, "OWNER").andExpect(status().isForbidden());
    }

    // ─── Cadastro de agente com empresa (bootstrap do tenant) ──────────────────

    @Test
    void registeringAnAgentWithCompanyCreatesTheCompanyAndMakesHimOwner() throws Exception {
        mockMvc.perform(post("/api/auth/cadastrar/agente")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registration(
                                "Diego Fundador", "diego@novaera.com.br", "Nova Era Turismo", "NovaEra.com.br", "BASIC"))))
                .andExpect(status().isOk());

        String token = login("diego@novaera.com.br", PASSWORD);
        mockMvc.perform(get("/api/companies/me").header("Authorization", bearer(token)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("Nova Era Turismo"))
                .andExpect(jsonPath("$.data.domain").value("novaera.com.br"))
                .andExpect(jsonPath("$.data.plan").value("BASIC"))
                .andExpect(jsonPath("$.data.currentAgent.role").value("OWNER"));
    }

    @Test
    void registeringWithAnExistingDomainIsRejected() throws Exception {
        mockMvc.perform(post("/api/auth/cadastrar/agente")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registration(
                                "Intruso", "intruso@aurora.com.br", "Aurora Clone", "aurora.com.br", "FREE"))))
                .andExpect(status().isBadRequest());

        assertTrue(agentUserRepository.findByEmail("intruso@aurora.com.br").isEmpty());
    }

    @Test
    void registeringWithEmailOutsideTheCompanyDomainIsRejected() throws Exception {
        mockMvc.perform(post("/api/auth/cadastrar/agente")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registration(
                                "Fora", "fora@gmail.com", "Empresa X", "empresax.com.br", "FREE"))))
                .andExpect(status().isBadRequest());

        assertTrue(companyRepository.findByDomainIgnoreCase("empresax.com.br").isEmpty());
    }

    @Test
    void registeringWithoutCompanyKeepsLegacyBehavior() throws Exception {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("name", "Legado");
        body.put("email", "legado@matrix.com");
        body.put("password", PASSWORD);
        body.put("role", "OWNER"); // ignorado: papel só existe dentro de uma empresa

        mockMvc.perform(post("/api/auth/cadastrar/agente")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk());

        AgentUser legacy = agentUserRepository.findByEmail("legado@matrix.com").orElseThrow();
        assertEquals(null, legacy.getCompany());
        assertEquals(null, legacy.getRole());
    }

    // ─── Integridade login × domínio ───────────────────────────────────────────

    @Test
    void loginIsRejectedWhenEmailDomainDoesNotMatchTheCompany() throws Exception {
        saveAgent("Inconsistente", "inconsistente@outrodominio.com", aurora, AgentRole.MEMBER);

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("email", "inconsistente@outrodominio.com", "password", PASSWORD))))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/auth/login/agente")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("email", "inconsistente@outrodominio.com", "password", PASSWORD))))
                .andExpect(status().isBadRequest());
    }

    // ─── helpers ───────────────────────────────────────────────────────────────

    private Company saveCompany(String name, String domain, PlanType plan) {
        Company company = new Company();
        company.setName(name);
        company.setCnpj("12.345.678/0001-90");
        company.setDomain(domain);
        company.setPlan(plan);
        return companyRepository.save(company);
    }

    private AgentUser saveAgent(String name, String email, Company company, AgentRole role) {
        AgentUser agent = new AgentUser();
        agent.setName(name);
        agent.setEmail(email);
        agent.setPassword(BCrypt.hashpw(PASSWORD, BCrypt.gensalt()));
        agent.setCompany(company);
        agent.setRole(role);
        return agentUserRepository.save(agent);
    }

    private Map<String, Object> registration(String name, String email,
                                             String companyName, String domain, String plan) {
        Map<String, Object> company = new LinkedHashMap<>();
        company.put("name", companyName);
        company.put("cnpj", "98.765.432/0001-10");
        company.put("domain", domain);
        company.put("plan", plan);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("name", name);
        body.put("email", email);
        body.put("password", PASSWORD);
        body.put("company", company);
        return body;
    }

    private String login(String email, String password) throws Exception {
        String body = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("email", email, "password", password, "expectedUserType", "AGENTE"))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        JsonNode node = objectMapper.readTree(body);
        return node.at("/data/token").asText();
    }

    private org.springframework.test.web.servlet.ResultActions invite(String name) throws Exception {
        return mockMvc.perform(post("/api/companies/me/agents/invite")
                .header("Authorization", bearer(ownerToken))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of("name", name))));
    }

    private org.springframework.test.web.servlet.ResultActions changeRole(String token, Long agentId, String role)
            throws Exception {
        return mockMvc.perform(put("/api/companies/me/agents/" + agentId + "/role")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of("role", role))));
    }

    private static String bearer(String token) {
        return "Bearer " + token;
    }
}
