package com.compass.compass_system.transport;

import com.compass.compass_system.geo.Coordinate;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("airplane")
public class Airplane extends Transport {

    private String flightNumber;
    private String companyName;
    private String flightDate;
    private String departureGate;
    private String departureAirport;
    private String arrivalAirport;

    @Embedded
    @AttributeOverride(name = "latitude", column = @Column(name = "departure_airport_latitude"))
    @AttributeOverride(name = "longitude", column = @Column(name = "departure_airport_longitude"))
    private Coordinate departureAirportCoordinate;

    @Embedded
    @AttributeOverride(name = "latitude", column = @Column(name = "arrival_airport_latitude"))
    @AttributeOverride(name = "longitude", column = @Column(name = "arrival_airport_longitude"))
    private Coordinate arrivalAirportCoordinate;

    public Airplane() {
        setType("airplane");
    }

    public String getFlightNumber() { return flightNumber; }
    public void setFlightNumber(String flightNumber) { this.flightNumber = flightNumber; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getFlightDate() { return flightDate; }
    public void setFlightDate(String flightDate) { this.flightDate = flightDate; }

    public String getDepartureGate() { return departureGate; }
    public void setDepartureGate(String departureGate) { this.departureGate = departureGate; }

    public String getDepartureAirport() { return departureAirport; }
    public void setDepartureAirport(String departureAirport) { this.departureAirport = departureAirport; }

    public String getArrivalAirport() { return arrivalAirport; }
    public void setArrivalAirport(String arrivalAirport) { this.arrivalAirport = arrivalAirport; }

    public Coordinate getDepartureAirportCoordinate() { return departureAirportCoordinate; }
    public void setDepartureAirportCoordinate(Coordinate departureAirportCoordinate) { this.departureAirportCoordinate = departureAirportCoordinate; }

    public Coordinate getArrivalAirportCoordinate() { return arrivalAirportCoordinate; }
    public void setArrivalAirportCoordinate(Coordinate arrivalAirportCoordinate) { this.arrivalAirportCoordinate = arrivalAirportCoordinate; }
}
