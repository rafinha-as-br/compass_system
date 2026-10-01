package com.compass.compass_system.transport;

import com.compass.compass_system.geo.Coordinate;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("rental_car")
public class RentalCar extends Transport {

    private String vehicleModelName;
    private String vehicleLicensePlate;
    private String companyName;
    private String checkInDate;
    private String checkOutDate;

    // O modelo original não tinha nenhum campo de local de retirada — CPS-153
    // adicionou este campo para ter onde anexar a coordenada (decidido com
    // Rafinha durante a execução; RentalCar.java, ao contrário de Airplane e
    // Bus, não guardava texto livre de local nenhum antes desta entrega).
    private String pickupLocation;

    @Embedded
    @AttributeOverride(name = "latitude", column = @Column(name = "pickup_location_latitude"))
    @AttributeOverride(name = "longitude", column = @Column(name = "pickup_location_longitude"))
    private Coordinate pickupLocationCoordinate;

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

    public String getPickupLocation() { return pickupLocation; }
    public void setPickupLocation(String pickupLocation) { this.pickupLocation = pickupLocation; }

    public Coordinate getPickupLocationCoordinate() { return pickupLocationCoordinate; }
    public void setPickupLocationCoordinate(Coordinate pickupLocationCoordinate) { this.pickupLocationCoordinate = pickupLocationCoordinate; }
}
