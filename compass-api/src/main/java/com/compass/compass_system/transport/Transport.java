package com.compass.compass_system.transport;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import jakarta.persistence.*;

@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "transport_type", discriminatorType = DiscriminatorType.STRING)
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type", visible = true)
@JsonSubTypes({
    @JsonSubTypes.Type(value = PlaceholderTransport.class, name = "placeholder"),
    @JsonSubTypes.Type(value = RentalCar.class,            name = "rental_car"),
    @JsonSubTypes.Type(value = Bus.class,                  name = "bus"),
    @JsonSubTypes.Type(value = Airplane.class,             name = "airplane")
})
public abstract class Transport {

    @Id
    private String id;

    private String type;

    @PrePersist
    private void ensureId() {
        if (this.id == null || this.id.isBlank()) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
}
