package com.compass.compass_system.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.CascadeType;
import jakarta.persistence.JoinColumn;
import java.util.List;

@Entity
public class Itinerary {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String responsibleAgentName;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "itinerary_id")
    private List<Hosting> accommodationsList;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "itinerary_id")
    private List<ItineraryStop> listOfStops;

    public Itinerary() {}

    public String getId() {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public String getResponsibleAgentName() {
        return responsibleAgentName;
    }
    public void setResponsibleAgentName(String responsibleAgentName) {
        this.responsibleAgentName = responsibleAgentName;
    }
    public List<Hosting> getAccommodationsList() {
        return accommodationsList;
    }
    public void setAccommodationsList(List<Hosting> accommodationsList) {
        this.accommodationsList = accommodationsList;
    }
    public List<ItineraryStop> getListOfStops() {
        return listOfStops;
    }
    public void setListOfStops(List<ItineraryStop> listOfStops) {
        this.listOfStops = listOfStops;
    }
}
