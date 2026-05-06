package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.Travel;
import com.compass.compass_system.exceptions.ResourceNotFoundException;
import com.compass.compass_system.repositories.TravelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/travel")
public class TravelController {

    @Autowired
    private TravelRepository travelRepository;

    // Cria uma nova viagem
    @PostMapping
    public ResponseEntity<Travel> createTravel(@RequestBody Travel travel) {
        Travel savedTravel = travelRepository.save(travel);
        return ResponseEntity.ok(savedTravel);
    }

    // Lista todas as viagens
    @GetMapping
    public ResponseEntity<List<Travel>> getAllTravels() {
        List<Travel> travels = travelRepository.findAll();
        return ResponseEntity.ok(travels);
    }

    // Busca uma viagem por ID
    @GetMapping("/{id}")
    public ResponseEntity<Travel> getTravel(@PathVariable String id) {
        Travel travel = travelRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Viagem com ID '" + id + "' não encontrada."));
        return ResponseEntity.ok(travel);
    }

    // Lista as viagens de um cliente específico
    @GetMapping("/cliente/{clientId}")
    public ResponseEntity<List<Travel>> getTravelsByClient(@PathVariable String clientId) {
        List<Travel> travels = travelRepository.findByClientId(clientId);
        return ResponseEntity.ok(travels);
    }

    // Lista as viagens de um agente específico
    @GetMapping("/agente/{agentId}")
    public ResponseEntity<List<Travel>> getTravelsByAgent(@PathVariable String agentId) {
        List<Travel> travels = travelRepository.findByAgentId(agentId);
        return ResponseEntity.ok(travels);
    }
}
