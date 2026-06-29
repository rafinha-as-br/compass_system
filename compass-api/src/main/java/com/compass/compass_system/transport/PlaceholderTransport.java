package com.compass.compass_system.transport;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("placeholder")
public class PlaceholderTransport extends Transport {

    private String description;

    public PlaceholderTransport() {
        setType("placeholder");
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
