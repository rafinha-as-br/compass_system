package com.compass.compass_system.dto;

/**
 * DTO (Data Transfer Object) que padroniza a resposta de login.
 * Retorna o token JWT e informações básicas do usuário autenticado.
 */
public class LoginResponse {
    private String token;
    private Long userId;
    private String name;
    private String email;
    private String userType;

    public LoginResponse(String token, Long userId, String name, String email, String userType) {
        this.token = token;
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.userType = userType;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }
}
