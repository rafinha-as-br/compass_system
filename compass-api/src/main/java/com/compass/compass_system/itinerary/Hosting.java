package com.compass.compass_system.itinerary;

import com.compass.compass_system.geo.Coordinate;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("hosting")
public class Hosting extends ItineraryStep {

    private String name;
    private String address;
    private String checkIn;
    private String checkOut;

    @Embedded
    private Coordinate coordinate;

    public Hosting() {
        setType("hosting");
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCheckIn() { return checkIn; }
    public void setCheckIn(String checkIn) { this.checkIn = checkIn; }

    public String getCheckOut() { return checkOut; }
    public void setCheckOut(String checkOut) { this.checkOut = checkOut; }

    public Coordinate getCoordinate() { return coordinate; }
    public void setCoordinate(Coordinate coordinate) { this.coordinate = coordinate; }
}
