package com.compass.compass_system.repositories;

import com.compass.compass_system.entities.ClientUser;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ClientUserRepository extends JpaRepository<ClientUser, Long> {
    Optional<ClientUser> findByEmail(String email);
}
