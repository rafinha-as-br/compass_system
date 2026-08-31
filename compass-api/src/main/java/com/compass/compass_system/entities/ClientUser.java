package com.compass.compass_system.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

import java.time.Instant;

@Entity
public class ClientUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String cpf;
    private Integer age;
    private String gender;
    private String phone;
    private String email;
    private String password;
    private boolean isActive = true;
    private String deactivationReason;

    // Tokens emitidos antes deste instante são rejeitados pelo
    // JwtAuthenticationFilter — é o que dá efeito real ao force-logout
    // (JWT é stateless, então isso é a única forma de invalidar uma sessão
    // já emitida antes do seu vencimento natural).
    private Instant sessionInvalidatedAt;

    public ClientUser() {
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public String getDeactivationReason() {
        return deactivationReason;
    }

    public void setDeactivationReason(String deactivationReason) {
        this.deactivationReason = deactivationReason;
    }

    public Instant getSessionInvalidatedAt() {
        return sessionInvalidatedAt;
    }

    public void setSessionInvalidatedAt(Instant sessionInvalidatedAt) {
        this.sessionInvalidatedAt = sessionInvalidatedAt;
    }
}
