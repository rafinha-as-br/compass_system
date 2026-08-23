package com.compass.compass_system.travel;

import com.compass.compass_system.itinerary.Itinerary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/travels")
@CrossOrigin(origins = "*")
public class TravelController {

    @Autowired
    private TravelRepository travelRepository;

    // ─── GET /travels ───────────────────────────────────────────────────────────
    // Returns all travels.
    @GetMapping
    public ResponseEntity<List<Travel>> getAllTravels() {
        List<Travel> travels = travelRepository.findAll();
        return ResponseEntity.ok(travels);
    }

    // ─── GET /travels/client/{clientName} ───────────────────────────────────────
    // Returns all travels for a specific client.
    @GetMapping("/client/{clientName}")
    public ResponseEntity<List<Travel>> getTravelsByClient(@PathVariable String clientName) {
        List<Travel> travels = travelRepository.findByClientName(clientName);
        return ResponseEntity.ok(travels);
    }

    // ─── POST /travels ─────────────────────────────────────────────────────────
    // Creates a new Travel. All nested id fields may be null; backend assigns them.
    @PostMapping
    public ResponseEntity<Travel> createTravel(@RequestBody Travel travel) {
        Travel saved = travelRepository.save(travel);
        return ResponseEntity.ok(saved);
    }

    // ─── GET /travels/{id} ─────────────────────────────────────────────────────
    // Returns the full nested Travel by ID.
    @GetMapping("/{id}")
    public ResponseEntity<Travel> getTravel(@PathVariable String id) {
        Optional<Travel> opt = travelRepository.findById(id);
        return opt.map(ResponseEntity::ok)
                  .orElse(ResponseEntity.notFound().build());
    }

    // ─── PUT /travels/{id} ─────────────────────────────────────────────────────
    // Full update: replaces all nested data. Preserves existing IDs when provided.
    @PutMapping("/{id}")
    public ResponseEntity<Travel> updateTravel(@PathVariable String id, @RequestBody Travel incoming) {
        if (!travelRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        // Force the path-variable ID onto the entity so JPA knows this is an update.
        incoming.setId(id);

        Travel saved = travelRepository.save(incoming);
        return ResponseEntity.ok(saved);
    }

    // ─── DELETE /travels/{id} ──────────────────────────────────────────────────
    // Deletes the Travel and cascades to all nested entities.
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTravel(@PathVariable String id) {
        if (!travelRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        travelRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // ─── PUT /travels/{travelId}/itinerary ─────────────────────────────────────
    // Upsert: creates or fully replaces the Itinerary on a Travel.
    // Transitions travelStatus to "itinerary_created" when creating for the first time.
    @PutMapping("/{travelId}/itinerary")
    public ResponseEntity<Itinerary> upsertItinerary(
            @PathVariable String travelId,
            @RequestBody Itinerary incoming) {

        Optional<Travel> opt = travelRepository.findById(travelId);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Travel travel = opt.get();

        // Transition status the first time an itinerary is set.
        if (travel.getItinerary() == null) {
            travel.setTravelStatus("itinerary_created");
        }

        // Fully replace the itinerary (orphanRemoval handles deleting the old one).
        travel.setItinerary(incoming);

        Travel saved = travelRepository.save(travel);
        return ResponseEntity.ok(saved.getItinerary());
    }

    // ─── PUT /travels/{travelId}/route ─────────────────────────────────────────
    // Upsert: creates or fully replaces the RoutePlan on a Travel.
    @PutMapping("/{travelId}/route")
    public ResponseEntity<RoutePlan> upsertRoutePlan(
            @PathVariable String travelId,
            @RequestBody RoutePlan incoming) {

        Optional<Travel> opt = travelRepository.findById(travelId);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Travel travel = opt.get();

        // Fully replace the route plan (orphanRemoval handles deleting the old one).
        travel.setRoutePlan(incoming);

        Travel saved = travelRepository.save(travel);
        return ResponseEntity.ok(saved.getRoutePlan());
    }
}
