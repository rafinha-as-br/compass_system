package com.compass.compass_system.travel;

import com.compass.compass_system.itinerary.Itinerary;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
public class Travel {

    @Id
    private String id;

    private String clientName;
    private String travelName;
    private String travelStatus;

    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "route_plan_id")
    private RoutePlan routePlan;

    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "itinerary_id")
    private Itinerary itinerary;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "travel_id")
    private List<Person> participants = new ArrayList<>();

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "travel_id")
    private List<TravelEvent> events = new ArrayList<>();

    @PrePersist
    private void ensureId() {
        if (this.id == null || this.id.isBlank()) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getClientName() { return clientName; }
    public void setClientName(String clientName) { this.clientName = clientName; }

    public String getTravelName() { return travelName; }
    public void setTravelName(String travelName) { this.travelName = travelName; }

    public String getTravelStatus() { return travelStatus; }
    public void setTravelStatus(String travelStatus) { this.travelStatus = travelStatus; }

    public RoutePlan getRoutePlan() { return routePlan; }
    public void setRoutePlan(RoutePlan routePlan) { this.routePlan = routePlan; }

    public Itinerary getItinerary() { return itinerary; }
    public void setItinerary(Itinerary itinerary) { this.itinerary = itinerary; }

    public List<Person> getParticipants() { return participants; }
    public void setParticipants(List<Person> participants) { this.participants = participants; }

    public List<TravelEvent> getEvents() { return events; }
    public void setEvents(List<TravelEvent> events) { this.events = events; }
}
