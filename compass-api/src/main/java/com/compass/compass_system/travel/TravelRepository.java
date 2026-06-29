package com.compass.compass_system.travel;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TravelRepository extends JpaRepository<Travel, String> {
    List<Travel> findByClientName(String clientName);
    long countByItineraryIsNotNull();
}
