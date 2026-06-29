package com.compass.compass_system.controllers;

import com.compass.compass_system.entities.ClientUser;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.compass.compass_system.travel.Travel;
import com.compass.compass_system.travel.TravelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Controller para estatísticas do Dashboard do Travel Matrix.
 * Agrega dados de travels e clients para exibir KPIs.
 */
@RestController
@RequestMapping("/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired
    private TravelRepository travelRepository;

    @Autowired
    private ClientUserRepository clientRepository;

    // ─── GET /dashboard/stats ──────────────────────────────────────────────────
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        long totalTravels = travelRepository.count();
        long completedItineraries = travelRepository.countByItineraryIsNotNull();
        long pendingItineraries = totalTravels - completedItineraries;
        long activeClients = clientRepository.countByIsActiveTrue();

        // Recent travels (last 10)
        List<Travel> allTravels = travelRepository.findAll();
        List<Travel> recentTravels = allTravels.stream()
                .sorted((a, b) -> {
                    // Sort by id descending as a proxy for creation order
                    return b.getId().compareTo(a.getId());
                })
                .limit(10)
                .collect(Collectors.toList());

        // Active clients list
        List<ClientUser> activeClientsList = clientRepository.findByIsActiveTrue();
        List<Map<String, Object>> clientMaps = activeClientsList.stream()
                .map(client -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", String.valueOf(client.getId()));
                    m.put("name", client.getName());
                    m.put("email", client.getEmail());
                    m.put("phoneNumber", client.getPhone());
                    return m;
                })
                .collect(Collectors.toList());

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("totalTravels", (int) totalTravels);
        data.put("completedItineraries", (int) completedItineraries);
        data.put("pendingItineraries", (int) pendingItineraries);
        data.put("activeClients", (int) activeClients);
        data.put("recentTravels", recentTravels);
        data.put("activeClientsList", clientMaps);

        response.put("data", data);
        response.put("message", null);

        return ResponseEntity.ok(response);
    }
}
