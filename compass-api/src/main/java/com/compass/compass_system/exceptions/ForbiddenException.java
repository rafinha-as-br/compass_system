package com.compass.compass_system.exceptions;

/**
 * Exceção para quando o usuário está autenticado mas não tem permissão para a
 * operação. Ex: MEMBER tentando gerenciar agentes da empresa (só OWNER pode).
 */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }
}
