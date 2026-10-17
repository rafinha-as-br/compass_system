package com.compass.compass_system.company;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.exceptions.ForbiddenException;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * Empresa (tenant) de quem está chamando, resolvida a partir do token já
 * autenticado pelo JwtAuthenticationFilter — agente ou cliente. É a base do
 * isolamento por empresa: toda rota de viagem e de cliente compara o
 * companyId do registro com o devolvido aqui.
 */
@Component
public class CompanyScope {

    private final AgentUserRepository agentRepository;
    private final ClientUserRepository clientRepository;

    public CompanyScope(AgentUserRepository agentRepository, ClientUserRepository clientRepository) {
        this.agentRepository = agentRepository;
        this.clientRepository = clientRepository;
    }

    public Company currentCompany() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            throw new ForbiddenException("Autenticação obrigatória.");
        }
        String email = auth.getName();
        Company company = isAgent(auth)
                ? agentRepository.findByEmail(email).map(AgentUser::getCompany).orElse(null)
                : clientRepository.findByEmail(email).map(ClientUser::getCompany).orElse(null);
        if (company == null) {
            throw new ForbiddenException("Usuário sem empresa vinculada.");
        }
        return company;
    }

    public Long currentCompanyId() {
        return currentCompany().getId();
    }

    /** Agente autenticado; recusa token de cliente. */
    public AgentUser currentAgent() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !isAgent(auth)) {
            throw new ForbiddenException("Apenas agentes podem realizar esta operação.");
        }
        return agentRepository.findByEmail(auth.getName())
                .orElseThrow(() -> new ForbiddenException("Agente não encontrado."));
    }

    private static boolean isAgent(Authentication auth) {
        return auth.getAuthorities().stream().anyMatch(a -> "ROLE_AGENTE".equals(a.getAuthority()));
    }
}
