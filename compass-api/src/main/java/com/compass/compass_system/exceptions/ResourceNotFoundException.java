package com.compass.compass_system.exceptions;

/**
 * Exceção customizada para quando um recurso não é encontrado no banco de dados.
 * Ex: buscar uma viagem com ID que não existe.
 */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
