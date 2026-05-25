package com.compass.compass_system.itinerary;

import com.compass.compass_system.transport.Transport;
import jakarta.persistence.*;

@Entity
@DiscriminatorValue("travel_segment")
public class TravelSegment extends ItineraryStep {

    private String startPoint;
    private String finishPoint;

    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "transport_id")
    private Transport transport;

    public TravelSegment() {
        setType("travel_segment");
    }

    public String getStartPoint() { return startPoint; }
    public void setStartPoint(String startPoint) { this.startPoint = startPoint; }

    public String getFinishPoint() { return finishPoint; }
    public void setFinishPoint(String finishPoint) { this.finishPoint = finishPoint; }

    public Transport getTransport() { return transport; }
    public void setTransport(Transport transport) { this.transport = transport; }
}
