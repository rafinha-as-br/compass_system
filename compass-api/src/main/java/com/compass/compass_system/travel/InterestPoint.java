package com.compass.compass_system.travel;

import com.compass.compass_system.geo.Coordinate;
import jakarta.persistence.*;

@Entity
public class InterestPoint {

    @Id
    private String id;

    private String name;
    private String description;

    // Free-text note about this point, written by the client and editable by
    // the agent (CPS-180). Distinct from Travel.observations, which stays the
    // single note for the whole trip. Null = no observation. Blank is stored
    // as null; text over OBSERVATION_MAX_LENGTH is rejected by TravelController
    // rather than cut, so the setter keeps the full text for that check.
    @Column(length = OBSERVATION_MAX_LENGTH)
    private String observation;

    public static final int OBSERVATION_MAX_LENGTH = 500;

    @Embedded
    private Coordinate coordinate;

    @PrePersist
    private void ensureId() {
        if (this.id == null || this.id.isBlank()) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getObservation() { return observation; }
    public void setObservation(String observation) {
        String trimmed = observation == null ? "" : observation.trim();
        this.observation = trimmed.isEmpty() ? null : trimmed;
    }

    public Coordinate getCoordinate() { return coordinate; }
    public void setCoordinate(Coordinate coordinate) { this.coordinate = coordinate; }
}
