package com.compass.compass_system.places;

import java.util.List;

/**
 * Abstrai o provedor de geocodificação por trás da fachada — hoje só o
 * Nominatim ({@link NominatimClient}), mas troca de provedor não deve
 * tocar em {@link PlaceAutocompleteService}. Também é o que permite testar
 * o serviço sem chamada de rede real.
 */
public interface PlaceProvider {
    List<PlaceSuggestion> search(String query);
}
