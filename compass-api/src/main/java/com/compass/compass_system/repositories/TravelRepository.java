package com.compass.compass_system.repositories;

import com.compass.compass_system.entities.Travel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TravelRepository extends JpaRepository<Travel, String> {
    List<Travel> findByClientId(String clientId);
    List<Travel> findByAgentId(String agentId);
}
