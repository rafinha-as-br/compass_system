package com.compass.compass_system.company;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.exceptions.ForbiddenException;
import com.compass.compass_system.exceptions.ResourceNotFoundException;
import com.compass.compass_system.repositories.AgentUserRepository;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;

/**
 * Regras de negócio do módulo company: criação da empresa, geração do login
 * dos agentes a partir do domínio, convite/remoção/troca de papel e as guardas
 * de OWNER (só OWNER gerencia; a empresa nunca fica sem OWNER).
 */
@Service
public class CompanyService {

    private static final String PASSWORD_ALPHABET =
            "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
    private static final int TEMPORARY_PASSWORD_LENGTH = 10;

    private final CompanyRepository companyRepository;
    private final AgentUserRepository agentRepository;
    private final SecureRandom random = new SecureRandom();

    public CompanyService(CompanyRepository companyRepository, AgentUserRepository agentRepository) {
        this.companyRepository = companyRepository;
        this.agentRepository = agentRepository;
    }

    /** Resultado do convite: o agente criado e a senha temporária em texto claro (exibida uma única vez). */
    public record InvitedAgent(AgentUser agent, String temporaryPassword) {
    }

    // ─── Empresa ───────────────────────────────────────────────────────────────

    public Company createCompany(String name, String cnpj, String rawDomain, PlanType plan) {
        if (name == null || name.isBlank()) {
            throw new BusinessException("O nome da empresa é obrigatório.");
        }
        String domain = normalizeDomain(rawDomain);
        if (companyRepository.existsByDomainIgnoreCase(domain)) {
            throw new BusinessException("Já existe uma empresa cadastrada com o domínio " + domain + ".");
        }

        Company company = new Company();
        company.setName(name.trim());
        company.setCnpj(cnpj);
        company.setDomain(domain);
        company.setPlan(plan != null ? plan : PlanType.FREE);
        return companyRepository.save(company);
    }

    /** Domínio sem "@", sem espaços, minúsculo. Ex.: " @Aurora.com.br " → "aurora.com.br". */
    public static String normalizeDomain(String rawDomain) {
        if (rawDomain == null) {
            throw new BusinessException("O domínio da empresa é obrigatório.");
        }
        String domain = rawDomain.trim().toLowerCase(Locale.ROOT);
        if (domain.startsWith("@")) {
            domain = domain.substring(1);
        }
        if (domain.isEmpty() || domain.contains("@") || domain.contains(" ") || !domain.contains(".")) {
            throw new BusinessException("Domínio da empresa inválido: " + rawDomain);
        }
        return domain;
    }

    // ─── Login gerado ──────────────────────────────────────────────────────────

    /**
     * Local-part derivado do nome: sem acentos, minúsculo, espaços (e "-"/"_") viram ".",
     * só [a-z0-9.]. Ex.: "Ana Paula Ribeiro" → "ana.paula.ribeiro".
     */
    public static String toLocalPart(String name) {
        if (name == null || name.isBlank()) {
            throw new BusinessException("O nome do agente é obrigatório.");
        }
        String normalized = Normalizer.normalize(name.trim(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .replaceAll("[\\s_-]+", ".")
                .replaceAll("[^a-z0-9.]", "")
                .replaceAll("\\.{2,}", ".")
                .replaceAll("^\\.|\\.$", "");
        if (normalized.isEmpty()) {
            throw new BusinessException("Não foi possível gerar um login a partir do nome informado.");
        }
        return normalized;
    }

    /**
     * Login completo e único: localPart@domain; em colisão dentro da empresa
     * recebe sufixo numérico incremental a partir de 2 (ana.paula → ana.paula2).
     * Como o domínio é único entre empresas, checar o e-mail globalmente
     * equivale a checar dentro da empresa.
     */
    public String generateLogin(String agentName, Company company) {
        String localPart = toLocalPart(agentName);
        String candidate = localPart + "@" + company.getDomain();
        int suffix = 2;
        while (agentRepository.existsByEmailIgnoreCase(candidate)) {
            candidate = localPart + suffix + "@" + company.getDomain();
            suffix++;
        }
        return candidate;
    }

    public static boolean loginMatchesDomain(String email, String domain) {
        if (email == null || domain == null) {
            return false;
        }
        int at = email.lastIndexOf('@');
        return at >= 0 && email.substring(at + 1).equalsIgnoreCase(domain);
    }

    /**
     * Checagem de integridade na autenticação: o sufixo do login precisa bater
     * com o domínio da empresa vinculada. Não é o isolamento multi-tenant em si
     * (esse é o companyId) — só detecta dado inconsistente.
     */
    public void assertLoginMatchesCompany(AgentUser agent) {
        Company company = agent.getCompany();
        if (company != null && !loginMatchesDomain(agent.getEmail(), company.getDomain())) {
            throw new BusinessException(
                    "Login inconsistente com o domínio da empresa. Contate o responsável pela empresa.");
        }
    }

    // ─── Acesso ────────────────────────────────────────────────────────────────

    public Company requireCompany(AgentUser agent) {
        Company company = agent.getCompany();
        if (company == null) {
            throw new ResourceNotFoundException("Agente não está vinculado a nenhuma empresa.");
        }
        return company;
    }

    public void assertOwner(AgentUser agent) {
        if (agent.getRole() != AgentRole.OWNER) {
            throw new ForbiddenException("Apenas agentes OWNER podem gerenciar os agentes da empresa.");
        }
    }

    // ─── Agentes ───────────────────────────────────────────────────────────────

    public List<AgentUser> listAgents(Company company) {
        return agentRepository.findByCompany_IdOrderByNameAsc(company.getId());
    }

    @Transactional
    public InvitedAgent inviteAgent(Company company, String name) {
        String login = generateLogin(name, company);
        String temporaryPassword = generateTemporaryPassword();

        AgentUser agent = new AgentUser();
        agent.setName(name.trim());
        agent.setEmail(login);
        agent.setPassword(BCrypt.hashpw(temporaryPassword, BCrypt.gensalt()));
        agent.setCompany(company);
        agent.setRole(AgentRole.MEMBER);

        return new InvitedAgent(agentRepository.save(agent), temporaryPassword);
    }

    /**
     * Remove o agente da empresa. Não há FK de Travel/Itinerary para o agente,
     * então nada é excluído em cascata; o token do agente removido passa a ser
     * rejeitado pelo JwtAuthenticationFilter (agente inexistente).
     */
    @Transactional
    public void removeAgent(Company company, Long agentId) {
        AgentUser target = findAgentInCompany(company, agentId);
        assertNotSoleOwner(company, target);
        agentRepository.delete(target);
    }

    @Transactional
    public AgentUser changeRole(Company company, Long agentId, AgentRole newRole) {
        if (newRole == null) {
            throw new BusinessException("Papel inválido. Use OWNER ou MEMBER.");
        }
        AgentUser target = findAgentInCompany(company, agentId);
        if (target.getRole() == newRole) {
            return target;
        }
        if (newRole == AgentRole.MEMBER) {
            assertNotSoleOwner(company, target);
        }
        target.setRole(newRole);
        return agentRepository.save(target);
    }

    private AgentUser findAgentInCompany(Company company, Long agentId) {
        return agentRepository.findByIdAndCompany_Id(agentId, company.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Agente não encontrado nesta empresa."));
    }

    /** A empresa nunca pode ficar sem OWNER: o único OWNER não pode ser removido nem rebaixado. */
    private void assertNotSoleOwner(Company company, AgentUser target) {
        if (target.getRole() == AgentRole.OWNER
                && agentRepository.countByCompany_IdAndRole(company.getId(), AgentRole.OWNER) <= 1) {
            throw new BusinessException("Você é o único OWNER da empresa — promova outro agente antes.");
        }
    }

    private String generateTemporaryPassword() {
        StringBuilder sb = new StringBuilder(TEMPORARY_PASSWORD_LENGTH);
        for (int i = 0; i < TEMPORARY_PASSWORD_LENGTH; i++) {
            sb.append(PASSWORD_ALPHABET.charAt(random.nextInt(PASSWORD_ALPHABET.length())));
        }
        return sb.toString();
    }
}
