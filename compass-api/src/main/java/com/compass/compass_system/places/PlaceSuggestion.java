package com.compass.compass_system.places;

/**
 * Contrato próprio do Compass para uma sugestão de lugar — nunca o payload
 * cru do provedor, para que trocar de provedor não vaze para os apps.
 */
public record PlaceSuggestion(String name, double latitude, double longitude) {
}
