package com.compass.compass_system.controllers;

import com.compass.compass_system.company.CompanyScope;
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

    @Autowired
    private CompanyScope companyScope;

    // ─── GET /dashboard/stats ──────────────────────────────────────────────────
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        Long companyId = companyScope.currentCompanyId();
        long totalTravels = travelRepository.countByCompany_Id(companyId);
        long completedItineraries = travelRepository.countByCompany_IdAndItineraryIsNotNull(companyId);
        long pendingItineraries = totalTravels - completedItineraries;
        long activeClients = clientRepository.countByCompany_IdAndIsActiveTrue(companyId);

        // Recent travels (last 10)
        List<Travel> allTravels = travelRepository.findByCompany_Id(companyId);
        List<Travel> recentTravels = allTravels.stream()
                .sorted((a, b) -> {
                    // Sort by id descending as a proxy for creation order
                    return b.getId().compareTo(a.getId());
                })
                .limit(10)
                .collect(Collectors.toList());

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "success");

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("totalTravels", (int) totalTravels);
        data.put("completedItineraries", (int) completedItineraries);
        data.put("pendingItineraries", (int) pendingItineraries);
        data.put("activeClients", (int) activeClients);
        data.put("recentTravels", recentTravels);

        response.put("data", data);
        response.put("message", null);

        return ResponseEntity.ok(response);
    }
}
