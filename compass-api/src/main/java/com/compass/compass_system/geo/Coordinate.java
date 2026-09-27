package com.compass.compass_system.geo;

import jakarta.persistence.Embeddable;

/**
 * Latitude/longitude de um lugar escolhido no autocomplete (CPS-152).
 * Embutido de forma NULÁVEL em toda entidade de local — todo registro
 * criado antes desta entrega, ou salvo com texto livre, não tem coordenada,
 * e isso não pode quebrar nenhuma tela (CPS-153).
 */
@Embeddable
public class Coordinate {

    private Double latitude;
    private Double longitude;

    public Coordinate() {
    }

    public Coordinate(Double latitude, Double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
}
