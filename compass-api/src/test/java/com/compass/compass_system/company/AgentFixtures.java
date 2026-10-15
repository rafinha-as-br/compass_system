package com.compass.compass_system.company;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.repositories.AgentUserRepository;

/** Cria agentes de teste já vinculados a uma empresa (company e role são obrigatórios). */
public final class AgentFixtures {

    private AgentFixtures() {
    }

    /** Garante que o agente do token exista (o filtro JWT rejeita agente inexistente). */
    public static void ensureOwner(AgentUserRepository agents, CompanyRepository companies, String email) {
        if (agents.findByEmail(email).isEmpty()) {
            saveOwner(agents, companies, "Agent", email, "hash");
        }
    }

    /** Salva um OWNER na empresa do domínio do e-mail, criando a empresa se ainda não existir. */
    public static AgentUser saveOwner(AgentUserRepository agents, CompanyRepository companies,
                                      String name, String email, String passwordHash) {
        String domain = email.substring(email.indexOf('@') + 1);
        Company company = companies.findByDomainIgnoreCase(domain).orElseGet(() -> {
            Company created = new Company();
            created.setName("Empresa " + domain);
            created.setDomain(domain);
            created.setPlan(PlanType.FREE);
            return companies.save(created);
        });

        AgentUser agent = new AgentUser();
        agent.setName(name);
        agent.setEmail(email);
        agent.setPassword(passwordHash);
        agent.setCompany(company);
        agent.setRole(AgentRole.OWNER);
        return agents.save(agent);
    }
}
