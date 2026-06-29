package com.compass.compass_system.transport;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("rental_car")
public class RentalCar extends Transport {

    private String vehicleModelName;
    private String vehicleLicensePlate;
    private String companyName;
    private String checkInDate;
    private String checkOutDate;

    public RentalCar() {
        setType("rental_car");
    }

    public String getVehicleModelName() { return vehicleModelName; }
    public void setVehicleModelName(String vehicleModelName) { this.vehicleModelName = vehicleModelName; }

    public String getVehicleLicensePlate() { return vehicleLicensePlate; }
    public void setVehicleLicensePlate(String vehicleLicensePlate) { this.vehicleLicensePlate = vehicleLicensePlate; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getCheckInDate() { return checkInDate; }
    public void setCheckInDate(String checkInDate) { this.checkInDate = checkInDate; }

    public String getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(String checkOutDate) { this.checkOutDate = checkOutDate; }
}
