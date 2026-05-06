package com.compass.compass_system.exceptions;

import com.compass.compass_system.dto.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

/**
 * Handler global de exceções. Captura erros em TODOS os controllers
 * e retorna uma resposta padronizada em JSON para o front-end.
 * 
 * Este é o padrão @ControllerAdvice do Spring, amplamente usado na indústria.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Trata erros quando o JSON enviado pelo front-end é inválido ou malformado.
     * Ex: enviar texto onde deveria ser um número, ou JSON sem fechar chaves.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleBadJson(HttpMessageNotReadableException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Requisição inválida",
                "O corpo da requisição está malformado ou contém dados com tipo incorreto."
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    /**
     * Trata erros quando um parâmetro de URL tem o tipo errado.
     * Ex: enviar "abc" onde deveria ser um número no path /api/travel/abc
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleTypeMismatch(MethodArgumentTypeMismatchException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Parâmetro inválido",
                "O parâmetro '" + ex.getName() + "' possui um valor inválido: " + ex.getValue()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    /**
     * Trata erros de recurso não encontrado (lançados manualmente nos controllers).
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                "Recurso não encontrado",
                ex.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    /**
     * Trata erros de regra de negócio (ex: email já cadastrado).
     */
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Erro de negócio",
                ex.getMessage()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    /**
     * Trata qualquer outra exceção inesperada (erro 500).
     * Isso evita que o stack trace do Java vaze para o front-end.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Erro interno do servidor",
                "Ocorreu um erro inesperado. Por favor, tente novamente mais tarde."
        );
        // Imprime o stack trace no console do servidor para depuração
        ex.printStackTrace();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
