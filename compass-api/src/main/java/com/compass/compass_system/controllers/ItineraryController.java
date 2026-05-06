package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.Itinerary;
import com.compass.compass_system.exceptions.ResourceNotFoundException;
import com.compass.compass_system.repositories.ItineraryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/itinerary")
public class ItineraryController {

    @Autowired
    private ItineraryRepository itineraryRepository;

    // Cria um novo roteiro
    @PostMapping
    public ResponseEntity<Itinerary> createItinerary(@RequestBody Itinerary itinerary) {
        Itinerary savedItinerary = itineraryRepository.save(itinerary);
        return ResponseEntity.ok(savedItinerary);
    }

    // Lista todos os roteiros
    @GetMapping
    public ResponseEntity<List<Itinerary>> getAllItineraries() {
        List<Itinerary> itineraries = itineraryRepository.findAll();
        return ResponseEntity.ok(itineraries);
    }

    // Busca um roteiro por ID
    @GetMapping("/{id}")
    public ResponseEntity<Itinerary> getItinerary(@PathVariable String id) {
        Itinerary itinerary = itineraryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Roteiro com ID '" + id + "' não encontrado."));
        return ResponseEntity.ok(itinerary);
    }
}
