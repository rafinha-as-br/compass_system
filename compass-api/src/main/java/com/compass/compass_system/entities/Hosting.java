package com.compass.compass_system.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import java.time.LocalDateTime;

@Entity
public class Hosting {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String address;
    private LocalDateTime checkIn;
    private LocalDateTime checkOut;

    public Hosting() {}

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getAddress() {
        return address;
    }
    public void setAddress(String address) {
        this.address = address;
    }
    public LocalDateTime getCheckIn() {
        return checkIn;
    }
    public void setCheckIn(LocalDateTime checkIn) {
        this.checkIn = checkIn;
    }
    public LocalDateTime getCheckOut() {
        return checkOut;
    }
    public void setCheckOut(LocalDateTime checkOut) {
        this.checkOut = checkOut;
    }
}
