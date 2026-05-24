package com.compass.compass_system.itinerary;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@DiscriminatorValue("stop")
public class Stop extends ItineraryStep {

    private String name;
    private String description;

    @ElementCollection
    @CollectionTable(name = "stop_experiences", joinColumns = @JoinColumn(name = "step_id"))
    @Column(name = "experience")
    private List<String> experiences = new ArrayList<>();

    public Stop() {
        setType("stop");
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<String> getExperiences() { return experiences; }
    public void setExperiences(List<String> experiences) { this.experiences = experiences; }
}
