package com.compass.compass_system.itinerary;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("placeholder")
public class PlaceholderStep extends ItineraryStep {

    private String description;

    public PlaceholderStep() {
        setType("placeholder");
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
