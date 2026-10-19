package com.compass.compass_system.security;

import com.compass.compass_system.entities.AgentUser;
import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

/**
 * Filtro que intercepta toda requisição HTTP para verificar
 * se existe um token JWT válido no header "Authorization".
 * 
 * Este é o padrão "Bearer Token" usado pela indústria:
 * Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    static final String PASSWORD_CHANGE_REQUIRED = "PASSWORD_CHANGE_REQUIRED";
    static final String PASSWORD_CHANGE_PATH = "/api/agents/me/password";
    static final String PROFILE_PATH = "/users/me";

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private ClientUserRepository clientUserRepository;

    @Autowired
    private AgentUserRepository agentUserRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

            if (jwtUtil.isTokenValid(token)) {
                String email = jwtUtil.getEmailFromToken(token);
                String userType = jwtUtil.getUserTypeFromToken(token);
                Optional<AgentUser> agent = "AGENTE".equals(userType)
                        ? agentUserRepository.findByEmail(email) : Optional.empty();

                if (!isSessionInvalidated(token, userType, email, agent)) {
                    // Cria uma autenticação com a role do tipo de usuário
                    var authorities = List.of(new SimpleGrantedAuthority("ROLE_" + userType.toUpperCase()));
                    var authentication = new UsernamePasswordAuthenticationToken(email, null, authorities);

                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    if (agent.filter(AgentUser::isMustChangePassword).isPresent() && !isAllowedWhilePasswordChangePending(request)) {
                        rejectPasswordChangeRequired(response);
                        return;
                    }
                }
            }
        }

        filterChain.doFilter(request, response);
    }

    // Agente com troca de senha obrigatória só alcança a própria troca e o perfil.
    private boolean isAllowedWhilePasswordChangePending(HttpServletRequest request) {
        String path = request.getRequestURI();
        return (PASSWORD_CHANGE_PATH.equals(path) && "PUT".equals(request.getMethod()))
                || (PROFILE_PATH.equals(path) && "GET".equals(request.getMethod()));
    }

    private void rejectPasswordChangeRequired(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"status\":403,\"error\":\"" + PASSWORD_CHANGE_REQUIRED
                + "\",\"message\":\"É necessário trocar a senha temporária antes de continuar.\"}");
    }

    /**
     * CLIENTE: um token emitido antes do force-logout do usuário é rejeitado
     * mesmo que ainda não tenha expirado naturalmente.
     *
     * AGENTE: um token de agente inexistente ou desativado (removido da empresa
     * pelo OWNER, módulo company) é rejeitado — é o que dá efeito real à
     * remoção, já que o JWT é stateless.
     */
    private boolean isSessionInvalidated(String token, String userType, String email, Optional<AgentUser> agent) {
        if ("AGENTE".equals(userType)) {
            return agent.filter(AgentUser::isActive).isEmpty();
        }

        if (!"CLIENTE".equals(userType)) {
            return false;
        }

        Optional<ClientUser> clientOpt = clientUserRepository.findByEmail(email);
        if (clientOpt.isEmpty()) {
            return false;
        }

        Instant invalidatedAt = clientOpt.get().getSessionInvalidatedAt();
        return invalidatedAt != null && jwtUtil.getIssuedAtFromToken(token).isBefore(invalidatedAt);
    }
}
