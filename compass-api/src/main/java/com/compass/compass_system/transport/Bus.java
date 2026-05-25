package com.compass.compass_system.transport;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("bus")
public class Bus extends Transport {

    private String travelNumber;
    private String travelCompany;
    private String departureGate;
    private String departureDateTime;
    private String busStationName;
    private String description;
    private String details;

    public Bus() {
        setType("bus");
    }

    public String getTravelNumber() { return travelNumber; }
    public void setTravelNumber(String travelNumber) { this.travelNumber = travelNumber; }

    public String getTravelCompany() { return travelCompany; }
    public void setTravelCompany(String travelCompany) { this.travelCompany = travelCompany; }

    public String getDepartureGate() { return departureGate; }
    public void setDepartureGate(String departureGate) { this.departureGate = departureGate; }

    public String getDepartureDateTime() { return departureDateTime; }
    public void setDepartureDateTime(String departureDateTime) { this.departureDateTime = departureDateTime; }

    public String getBusStationName() { return busStationName; }
    public void setBusStationName(String busStationName) { this.busStationName = busStationName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
}
