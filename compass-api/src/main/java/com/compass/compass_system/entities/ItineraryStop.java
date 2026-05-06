package com.compass.compass_system.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.ElementCollection;
import java.util.List;

@Entity
public class ItineraryStop {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String name;
    private String description;

    @ElementCollection
    private List<String> experiences;

    private boolean isCompleted;

    public ItineraryStop() {}

    public String getId() {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public List<String> getExperiences() {
        return experiences;
    }
    public void setExperiences(List<String> experiences) {
        this.experiences = experiences;
    }
    public boolean isCompleted() {
        return isCompleted;
    }
    public void setCompleted(boolean completed) {
        this.isCompleted = completed;
    }
}
