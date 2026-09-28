package com.compass.compass_system.travel;

import com.compass.compass_system.geo.Coordinate;
import jakarta.persistence.*;

@Entity
public class InterestPoint {

    @Id
    private String id;

    private String name;
    private String description;

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

    public Coordinate getCoordinate() { return coordinate; }
    public void setCoordinate(Coordinate coordinate) { this.coordinate = coordinate; }
}
