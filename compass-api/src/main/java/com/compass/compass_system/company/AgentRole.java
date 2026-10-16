package com.compass.compass_system.company;

/**
 * Papel de acesso do agente dentro da empresa. OWNER gerencia os agentes
 * (convidar, remover, alterar papel); MEMBER só consulta.
 */
public enum AgentRole {
    OWNER,
    MEMBER
}
