package com.compass.compass_system.repositories;

import com.compass.compass_system.entities.RoutePlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RoutePlanRepository extends JpaRepository<RoutePlan, Long> {
}
