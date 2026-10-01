package com.compass.compass_system.security;

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

            if (jwtUtil.isTokenValid(token) && !isSessionInvalidated(token)) {
                String email = jwtUtil.getEmailFromToken(token);
                String userType = jwtUtil.getUserTypeFromToken(token);

                // Cria uma autenticação com a role do tipo de usuário
                var authorities = List.of(new SimpleGrantedAuthority("ROLE_" + userType.toUpperCase()));
                var authentication = new UsernamePasswordAuthenticationToken(email, null, authorities);

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }

        filterChain.doFilter(request, response);
    }

    /**
     * CLIENTE: um token emitido antes do force-logout do usuário é rejeitado
     * mesmo que ainda não tenha expirado naturalmente.
     *
     * AGENTE: um token de agente que já não existe (removido da empresa pelo
     * OWNER, módulo company) é rejeitado — é o que dá efeito real à remoção,
     * já que o JWT é stateless.
     */
    private boolean isSessionInvalidated(String token) {
        String userType = jwtUtil.getUserTypeFromToken(token);
        String email = jwtUtil.getEmailFromToken(token);

        if ("AGENTE".equals(userType)) {
            return agentUserRepository.findByEmail(email).isEmpty();
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
