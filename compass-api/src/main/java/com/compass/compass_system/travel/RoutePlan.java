package com.compass.compass_system.travel;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
public class RoutePlan {

    @Id
    private String id;

    private String startDate;
    private String finishDate;
    private String startLocation;
    private String destination;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "route_plan_id")
    private List<InterestPoint> interestPoints = new ArrayList<>();

    @PrePersist
    private void ensureId() {
        if (this.id == null || this.id.isBlank()) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }

    public String getFinishDate() { return finishDate; }
    public void setFinishDate(String finishDate) { this.finishDate = finishDate; }

    public String getStartLocation() { return startLocation; }
    public void setStartLocation(String startLocation) { this.startLocation = startLocation; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public List<InterestPoint> getInterestPoints() { return interestPoints; }
    public void setInterestPoints(List<InterestPoint> interestPoints) { this.interestPoints = interestPoints; }
}
