package com.compass.compass_system.repositories;

import com.compass.compass_system.entities.Itinerary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ItineraryRepository extends JpaRepository<Itinerary, String> {
}
