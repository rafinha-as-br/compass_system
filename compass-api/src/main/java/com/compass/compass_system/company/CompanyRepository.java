package com.compass.compass_system.company;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CompanyRepository extends JpaRepository<Company, Long> {
    Optional<Company> findByDomainIgnoreCase(String domain);
    boolean existsByDomainIgnoreCase(String domain);
}
