package com.compass.compass_system.company;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/**
 * Empresa (tenant) dona dos dados de negócio. Cada AgentUser pertence a uma
 * empresa; o domínio de e-mail é único entre empresas e é a base do login
 * gerado para os agentes (localPart@domain).
 */
@Entity
public class Company {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String cnpj;

    // "domain" é palavra reservada no H2 (CREATE DOMAIN), por isso a coluna
    // recebe um nome explícito.
    @Column(name = "email_domain", nullable = false, unique = true)
    private String domain;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PlanType plan = PlanType.FREE;

    public Company() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCnpj() { return cnpj; }
    public void setCnpj(String cnpj) { this.cnpj = cnpj; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    public PlanType getPlan() { return plan; }
    public void setPlan(PlanType plan) { this.plan = plan; }
}
