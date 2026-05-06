package com.compass.compass_system.exceptions;

/**
 * Exceção customizada para erros de regra de negócio.
 * Ex: email já cadastrado, senha inválida, etc.
 */
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
