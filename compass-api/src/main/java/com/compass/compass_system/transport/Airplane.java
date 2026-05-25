package com.compass.compass_system.transport;

import jakarta.persistence.DiscriminatorValue;
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
}
