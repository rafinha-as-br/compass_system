package com.compass.compass_system.travel;

import com.compass.compass_system.company.Company;
import com.compass.compass_system.company.CompanyScope;
import com.compass.compass_system.exceptions.BusinessException;
import com.compass.compass_system.itinerary.Itinerary;
import com.compass.compass_system.notification.NotificationEvent;
import com.compass.compass_system.notification.NotificationRecipientType;
import com.compass.compass_system.notification.NotificationType;
import com.compass.compass_system.repositories.AgentUserRepository;
import com.compass.compass_system.repositories.ClientUserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

@RestController
@RequestMapping("/travels")
@CrossOrigin(origins = "*")
public class TravelController {

    @Autowired
    private TravelRepository travelRepository;

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private CompanyScope companyScope;

    @Autowired
    private AgentUserRepository agentRepository;

    @Autowired
    private ClientUserRepository clientRepository;

    @Autowired
    private ObjectMapper objectMapper;

    // Viagem de outra empresa responde como inexistente (404), nunca 403, para
    // não revelar que o id existe.
    private Optional<Travel> findOwned(String id) {
        return travelRepository.findByIdAndCompany_Id(id, companyScope.currentCompanyId());
    }

    // O agente e o cliente indicados na viagem precisam ser da mesma empresa de quem a cria.
    private void assertPeopleInCompany(Travel travel, Long companyId) {
        Long agentId = travel.getAgentId();
        if (agentId != null
                && agentRepository.findByIdAndCompany_IdAndRemovedAtIsNull(agentId, companyId).isEmpty()) {
            throw new BusinessException("O agente informado não pertence à empresa.");
        }
        Long clientId = travel.getClientId();
        if (clientId != null && clientRepository.findByIdAndCompany_Id(clientId, companyId).isEmpty()) {
            throw new BusinessException("O cliente informado não pertence à empresa.");
        }
    }

    // O agente recebe a viagem inteira (rascunho + publicado). O cliente só vê
    // o itinerário depois de "Preparar viagem" e sempre na versão publicada,
    // no mesmo campo `itinerary` (o RouteCraft não muda de contrato); antes
    // disso a API omite o itinerário e a viagem ainda consta como "route_created"
    // (CPS-191). Viagem preparada antes desta mudança não tem cópia publicada:
    // o rascunho vale como publicado.
    private Object viewFor(Travel travel) {
        if (companyScope.isCurrentAgent()) {
            return travel;
        }
        ObjectNode node = objectMapper.valueToTree(travel);
        Itinerary visible = !travel.isPrepared() ? null
                : travel.getPublishedItinerary() != null ? travel.getPublishedItinerary() : travel.getItinerary();
        node.set("itinerary", visible == null ? node.nullNode() : objectMapper.valueToTree(visible));
        node.remove("publishedItinerary");
        node.remove("itineraryDraftPending");
        if (!travel.isPrepared() && "itinerary_created".equals(travel.getTravelStatus())) {
            node.put("travelStatus", "route_created");
        }
        return node;
    }

    // Copia o itinerário sem ids: cada passo/transporte/etc. ganha id novo ao
    // persistir, então a cópia publicada nunca divide linhas com o rascunho.
    private Itinerary copyOf(Itinerary itinerary) {
        JsonNode tree = objectMapper.valueToTree(itinerary);
        stripIds(tree);
        try {
            return objectMapper.treeToValue(tree, Itinerary.class);
        } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
            throw new IllegalStateException("Não foi possível copiar o itinerário para publicação.", e);
        }
    }

    private static void stripIds(JsonNode node) {
        if (node.isObject()) {
            ((ObjectNode) node).remove("id");
        }
        node.forEach(TravelController::stripIds);
    }

    // ─── GET /travels ───────────────────────────────────────────────────────────
    // Returns all travels of the caller's company.
    @GetMapping
    public ResponseEntity<List<Object>> getAllTravels() {
        List<Object> travels = travelRepository.findByCompany_Id(companyScope.currentCompanyId())
                .stream().map(this::viewFor).toList();
        return ResponseEntity.ok(travels);
    }

    // ─── GET /travels/client/{clientName} ───────────────────────────────────────
    // Returns all travels for a specific client, within the caller's company.
    @GetMapping("/client/{clientName}")
    public ResponseEntity<List<Object>> getTravelsByClient(@PathVariable String clientName) {
        List<Object> travels = travelRepository.findByClientNameAndCompany_Id(
                clientName, companyScope.currentCompanyId()).stream().map(this::viewFor).toList();
        return ResponseEntity.ok(travels);
    }

    // ─── POST /travels ─────────────────────────────────────────────────────────
    // Creates a new Travel. All nested id fields may be null; backend assigns them.
    // @Transactional for the same reason as the upsert endpoints below: the
    // notification must never fire for a create that ends up rolled back.
    @Transactional
    @PostMapping
    public ResponseEntity<Travel> createTravel(@RequestBody Travel travel) {
        // Company comes from the caller's token (client or agent), never from the body.
        Company company = companyScope.currentCompany();
        assertPeopleInCompany(travel, company.getId());
        travel.setCompany(company);
        // A client-supplied id would make save() overwrite an existing travel (maybe another company's).
        travel.setId(null);
        Travel saved = travelRepository.save(travel);

        eventPublisher.publishEvent(new NotificationEvent(
                NotificationRecipientType.AGENT,
                saved.getAgentId(),
                NotificationType.ROUTE_CREATED,
                saved.getId(),
                "O cliente criou uma rota para a viagem \"" + saved.getTravelName() + "\"."));

        return ResponseEntity.ok(saved);
    }

    // ─── GET /travels/{id} ─────────────────────────────────────────────────────
    // Returns the full nested Travel by ID.
    @GetMapping("/{id}")
    public ResponseEntity<Object> getTravel(@PathVariable String id) {
        return findOwned(id).map(t -> ResponseEntity.ok(viewFor(t)))
                  .orElse(ResponseEntity.notFound().build());
    }

    // ─── PUT /travels/{id} ─────────────────────────────────────────────────────
    // Full update: replaces all nested data. Preserves existing IDs when provided.
    // "Preparar viagem" (prepared = true) is the only thing that publishes the
    // itinerary: the first confirmation, or one made while an edit of an
    // already published itinerary is still a pending draft (CPS-191).
    // @Transactional so the notification is committed with the publication.
    @Transactional
    @PutMapping("/{id}")
    public ResponseEntity<Travel> updateTravel(@PathVariable String id, @RequestBody Travel incoming) {
        Optional<Travel> opt = findOwned(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // "Preparar viagem" can only be confirmed once an itinerary exists —
        // enforced here too, not just by the frontend's disabled button, so
        // no other caller can flip prepared prematurely (CPS-166).
        if (incoming.isPrepared() && opt.get().getItinerary() == null) {
            return ResponseEntity.badRequest().build();
        }

        // Force the path-variable ID onto the entity so JPA knows this is an update.
        incoming.setId(id);

        // The tenant never changes, and a new agent/client must be from the same company.
        incoming.setCompany(opt.get().getCompany());
        if (!Objects.equals(incoming.getAgentId(), opt.get().getAgentId())
                || !Objects.equals(incoming.getClientId(), opt.get().getClientId())) {
            assertPeopleInCompany(incoming, opt.get().getCompany().getId());
        }

        // observations has no edit endpoint by design — a caller that doesn't
        // carry it forward (e.g. Travel Matrix re-submitting the travel just
        // to flip travelStatus) would otherwise silently wipe it here, the
        // one full-replace path that isn't isolated to its own sub-resource.
        incoming.setObservations(opt.get().getObservations());

        // Only the agent confirms "Preparar viagem"; a client token cannot flip
        // prepared (which would publish, and expose, the draft).
        if (!companyScope.isCurrentAgent()) {
            incoming.setPrepared(opt.get().isPrepared());
        }

        // The published copy and the pending-draft flag belong to the server.
        boolean firstPublish = !opt.get().isPrepared();
        boolean publish = incoming.isPrepared() && (firstPublish || opt.get().isItineraryDraftPending());
        incoming.setPublishedItinerary(opt.get().getPublishedItinerary());
        incoming.setItineraryDraftPending(opt.get().isItineraryDraftPending());

        Travel saved = travelRepository.save(incoming);

        if (publish && saved.getItinerary() != null) {
            saved.setPublishedItinerary(copyOf(saved.getItinerary()));
            saved.setItineraryDraftPending(false);
            saved = travelRepository.save(saved);

            eventPublisher.publishEvent(new NotificationEvent(
                    NotificationRecipientType.CLIENT,
                    saved.getClientId(),
                    firstPublish ? NotificationType.ITINERARY_PUBLISHED : NotificationType.ITINERARY_STEP_CHANGED,
                    saved.getId(),
                    firstPublish
                            ? "O itinerário da sua viagem \"" + saved.getTravelName() + "\" foi publicado."
                            : "O itinerário da sua viagem \"" + saved.getTravelName() + "\" foi atualizado."));
        }
        return ResponseEntity.ok(saved);
    }

    // ─── DELETE /travels/{id} ──────────────────────────────────────────────────
    // Deletes the Travel and cascades to all nested entities.
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTravel(@PathVariable String id) {
        Optional<Travel> opt = findOwned(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        travelRepository.delete(opt.get());
        return ResponseEntity.noContent().build();
    }

    // ─── PUT /travels/{travelId}/itinerary ─────────────────────────────────────
    // Upsert: creates or fully replaces the *draft* Itinerary on a Travel. Saving
    // never publishes or notifies the client (CPS-191): that only happens at
    // "Preparar viagem" (PUT /travels/{id} with prepared = true). Editing an
    // itinerary that was already published leaves the published copy untouched
    // and flags the draft as pending, so the agent can republish it.
    // Transitions travelStatus to "itinerary_created" when creating for the first time.
    @Transactional
    @PutMapping("/{travelId}/itinerary")
    public ResponseEntity<Itinerary> upsertItinerary(
            @PathVariable String travelId,
            @RequestBody Itinerary incoming) {

        Optional<Travel> opt = findOwned(travelId);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Travel travel = opt.get();

        // Transition status the first time an itinerary is set.
        if (travel.getItinerary() == null) {
            travel.setTravelStatus("itinerary_created");
        }
        if (travel.isPrepared()) {
            travel.setItineraryDraftPending(true);
        }

        // Fully replace the draft (orphanRemoval handles deleting the old one).
        travel.setItinerary(incoming);

        Travel saved = travelRepository.save(travel);
        return ResponseEntity.ok(saved.getItinerary());
    }

    // ─── PUT /travels/{travelId}/route ─────────────────────────────────────────
    // Upsert: creates or fully replaces the RoutePlan on a Travel.
    @Transactional
    @PutMapping("/{travelId}/route")
    public ResponseEntity<RoutePlan> upsertRoutePlan(
            @PathVariable String travelId,
            @RequestBody RoutePlan incoming) {

        Optional<Travel> opt = findOwned(travelId);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Travel travel = opt.get();
        boolean firstRoute = travel.getRoutePlan() == null;

        // Fully replace the route plan (orphanRemoval handles deleting the old one).
        travel.setRoutePlan(incoming);

        Travel saved = travelRepository.save(travel);

        eventPublisher.publishEvent(new NotificationEvent(
                NotificationRecipientType.AGENT,
                saved.getAgentId(),
                firstRoute ? NotificationType.ROUTE_CREATED : NotificationType.ROUTE_EDITED,
                saved.getId(),
                firstRoute
                        ? "O cliente criou uma rota para a viagem \"" + saved.getTravelName() + "\"."
                        : "O cliente editou a rota da viagem \"" + saved.getTravelName() + "\"."));

        return ResponseEntity.ok(saved.getRoutePlan());
    }

    // ─── PUT /travels/{travelId}/participants ──────────────────────────────────
    // Upsert: fully replaces the participants list on a Travel. Isolated from
    // route/itinerary, same pattern as upsertRoutePlan.
    @PutMapping("/{travelId}/participants")
    public ResponseEntity<List<Person>> upsertParticipants(
            @PathVariable String travelId,
            @RequestBody List<Person> incoming) {

        Optional<Travel> opt = findOwned(travelId);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Travel travel = opt.get();

        // Mutate the existing Hibernate-managed collection in place — handing
        // setParticipants a brand-new List instance instead (breaking its
        // link to the persistent collection) throws
        // "collection with cascade=all-delete-orphan was no longer
        // referenced" on flush. Clearing + re-adding lets orphanRemoval
        // delete what's no longer present and persist what's new.
        List<Person> participants = travel.getParticipants();
        participants.clear();
        participants.addAll(incoming);

        Travel saved = travelRepository.save(travel);
        return ResponseEntity.ok(saved.getParticipants());
    }
}
