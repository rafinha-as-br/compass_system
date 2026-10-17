package com.compass.compass_system.repositories;

import com.compass.compass_system.entities.ClientUser;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ClientUserRepository extends JpaRepository<ClientUser, Long> {
    Optional<ClientUser> findByEmail(String email);
    List<ClientUser> findByIsActiveTrue();
    List<ClientUser> findByCompany_Id(Long companyId);
    Optional<ClientUser> findByIdAndCompany_Id(Long id, Long companyId);
    long countByCompany_IdAndIsActiveTrue(Long companyId);
}
