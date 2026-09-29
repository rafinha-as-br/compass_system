package com.compass.compass_system.places;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/places")
@CrossOrigin(origins = "*")
public class PlaceController {

    private final PlaceAutocompleteService placeAutocompleteService;

    public PlaceController(PlaceAutocompleteService placeAutocompleteService) {
        this.placeAutocompleteService = placeAutocompleteService;
    }

    // ─── GET /places/autocomplete?query= ───────────────────────────────────────
    // Sugestões de lugar por texto parcial, com nome normalizado + coordenada.
    // Nominatim indisponível responde 503 (ver GlobalExceptionHandler) em vez
    // de travar o app — o campo do cliente degrada para texto livre nesse caso.
    @GetMapping("/autocomplete")
    public ResponseEntity<List<PlaceSuggestion>> autocomplete(@RequestParam String query) {
        return ResponseEntity.ok(placeAutocompleteService.autocomplete(query));
    }
}
