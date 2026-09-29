package com.compass.compass_system.transport;

import com.compass.compass_system.geo.Coordinate;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Embedded;
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

    @Embedded
    @AttributeOverride(name = "latitude", column = @Column(name = "bus_station_latitude"))
    @AttributeOverride(name = "longitude", column = @Column(name = "bus_station_longitude"))
    private Coordinate busStationCoordinate;

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

    public Coordinate getBusStationCoordinate() { return busStationCoordinate; }
    public void setBusStationCoordinate(Coordinate busStationCoordinate) { this.busStationCoordinate = busStationCoordinate; }
}
