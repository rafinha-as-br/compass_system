package com.compass.compass_system.places;

/**
 * O provedor externo de geocodificação (Nominatim) não respondeu ou
 * respondeu com erro. Tratada à parte de erros genéricos para que o
 * cliente saiba degradar para texto livre em vez de ver um 500 opaco.
 */
public class PlaceProviderUnavailableException extends RuntimeException {
    public PlaceProviderUnavailableException(String message) {
        super(message);
    }
}
