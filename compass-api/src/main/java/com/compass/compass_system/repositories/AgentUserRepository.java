package com.compass.compass_system.repositories;

import com.compass.compass_system.entities.AgentUser;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface AgentUserRepository extends JpaRepository<AgentUser, Long> {
    Optional<AgentUser> findByEmail(String email);
}
