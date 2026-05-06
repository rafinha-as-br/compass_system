package com.compass.compass_system.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.OneToOne;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.CascadeType;

@Entity
public class Travel {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String clientId;
    private String agentId;
    private String travelName;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "route_plan_id", referencedColumnName = "id")
    private RoutePlan routePlan;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "itinerary_id", referencedColumnName = "id")
    private Itinerary itinerary;

    public Travel() {}

    public String getId() {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public String getClientId() {
        return clientId;
    }
    public void setClientId(String clientId) {
        this.clientId = clientId;
    }
    public String getAgentId() {
        return agentId;
    }
    public void setAgentId(String agentId) {
        this.agentId = agentId;
    }
    public String getTravelName() {
        return travelName;
    }
    public void setTravelName(String travelName) {
        this.travelName = travelName;
    }
    public RoutePlan getRoutePlan() {
        return routePlan;
    }
    public void setRoutePlan(RoutePlan routePlan) {
        this.routePlan = routePlan;
    }
    public Itinerary getItinerary() {
        return itinerary;
    }
    public void setItinerary(Itinerary itinerary) {
        this.itinerary = itinerary;
    }
    public boolean isHasItinerary() {
        return itinerary != null;
    }
}
