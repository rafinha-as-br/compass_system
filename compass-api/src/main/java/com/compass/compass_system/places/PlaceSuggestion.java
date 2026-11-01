package com.compass.compass_system.places;

/**
 * Contrato próprio do Compass para uma sugestão de lugar — nunca o payload
 * cru do provedor, para que trocar de provedor não vaze para os apps.
 * {@code name} é o nome curto (cidade/local); {@code label} é o rótulo
 * completo (rua, número, bairro, cidade) para quem busca endereço.
 */
public record PlaceSuggestion(String name, String label, double latitude, double longitude) {
}
