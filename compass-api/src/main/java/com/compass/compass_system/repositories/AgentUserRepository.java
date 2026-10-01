package com.compass.compass_system.repositories;

import com.compass.compass_system.company.AgentRole;
import com.compass.compass_system.entities.AgentUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AgentUserRepository extends JpaRepository<AgentUser, Long> {
    Optional<AgentUser> findByEmail(String email);
    boolean existsByEmailIgnoreCase(String email);
    List<AgentUser> findByCompany_IdOrderByNameAsc(Long companyId);
    Optional<AgentUser> findByIdAndCompany_Id(Long id, Long companyId);
    long countByCompany_IdAndRole(Long companyId, AgentRole role);
}
