package com.compass.compass_system.itinerary;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
public class Itinerary {

    @Id
    private String id;

    private String agentName;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "itinerary_id")
    @OrderColumn(name = "step_order")
    private List<ItineraryStep> steps = new ArrayList<>();

    @PrePersist
    private void ensureId() {
        if (this.id == null || this.id.isBlank()) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getAgentName() { return agentName; }
    public void setAgentName(String agentName) { this.agentName = agentName; }

    public List<ItineraryStep> getSteps() { return steps; }
    public void setSteps(List<ItineraryStep> steps) { this.steps = steps; }
}
