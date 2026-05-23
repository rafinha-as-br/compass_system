# Travel Domain — Backend Entity Specification & API Contract

This document describes all entities, their JSON field names, and the required API endpoints
for the Travel domain. It was generated from the Flutter client's DTOs and domain entities.
The client is the source of truth for field names and structure.

---

## Important Rules

- **`domainId` is client-only** — never store or return it. It is a UUID the client generates
  locally for its own state management.
- **`backEndId` maps to your database `id`** — this is the only ID the API cares about.
- **No validation required on the backend** — the client app handles all input validation.
- **All dates are ISO 8601 strings** (e.g. `"2025-06-15T14:30:00.000Z"`).
- **Polymorphic fields** use a `"type"` string discriminator to determine the concrete subtype.

---

## 1. Entity Structures & JSON Field Names

### 1.1 Travel (Root Aggregate)

This is the root object. It contains all nested entities.

| JSON Field       | Type              | Nullable | Notes                                      |
|------------------|-------------------|----------|--------------------------------------------|
| `id`             | `String`          | Yes      | Null on creation, assigned by backend      |
| `clientName`     | `String`          | No       |                                            |
| `travelName`     | `String`          | No       |                                            |
| `travelStatus`   | `String` (enum)   | No       | See TravelStatus values below              |
| `startDate`      | `String` (ISO)    | No       | Comes from the nested RoutePlan            |
| `finishDate`     | `String` (ISO)    | No       | Comes from the nested RoutePlan            |
| `routePlan`      | `RoutePlan`       | No       | Full nested object                         |
| `itinerary`      | `Itinerary`       | Yes      | Null until agent creates the itinerary     |
| `participants`   | `Person[]`        | No       | Can be empty list                          |
| `events`         | `TravelEvent[]`   | Yes      | Null or empty list                         |

**TravelStatus enum values (API strings):**

| Client enum value    | API String          |
|----------------------|---------------------|
| `routeCreated`       | `"route_created"`   |
| `itineraryCreated`   | `"itinerary_created"` |
| `travelStarted`      | `"travel_started"`  |
| `travelFinished`     | `"travel_finished"` |

**Example Travel JSON:**
```json
{
  "id": "abc-123",
  "clientName": "John Doe",
  "travelName": "Europe Trip 2025",
  "travelStatus": "route_created",
  "routePlan": { ... },
  "itinerary": null,
  "participants": [],
  "events": null
}
```

---

### 1.2 RoutePlan

Nested inside `Travel`. Created by the client app (RouteCraft) before the agent builds the itinerary.

| JSON Field        | Type               | Nullable | Notes                        |
|-------------------|--------------------|----------|------------------------------|
| `id`              | `String`           | Yes      | Null on creation             |
| `startDate`       | `String` (ISO)     | No       |                              |
| `finishDate`      | `String` (ISO)     | No       |                              |
| `startLocation`   | `String`           | No       |                              |
| `destination`     | `String`           | No       |                              |
| `interestPoints`  | `InterestPoint[]`  | No       | Can be empty list            |

#### 1.2.1 InterestPoint

Nested inside `RoutePlan`.

| JSON Field    | Type     | Nullable | Notes            |
|---------------|----------|----------|------------------|
| `id`          | `String` | Yes      | Null on creation |
| `name`        | `String` | No       |                  |
| `description` | `String` | No       |                  |

---

### 1.3 Itinerary

Nested inside `Travel`. Created by the travel agent. May be null initially.

| JSON Field | Type              | Nullable | Notes                        |
|------------|-------------------|----------|------------------------------|
| `id`       | `String`          | Yes      | Null on creation             |
| `agentName`| `String`          | No       |                              |
| `steps`    | `ItineraryStep[]` | No       | Ordered list of steps        |

---

### 1.4 ItineraryStep (Polymorphic)

Each step has a `"type"` field that determines its concrete structure.
All step types share these **base fields**:

| JSON Field   | Type           | Nullable | Notes            |
|--------------|----------------|----------|------------------|
| `id`         | `String`       | Yes      | Null on creation |
| `type`       | `String` (enum)| No       | Discriminator    |
| `title`      | `String`       | No       |                  |
| `startDate`  | `String` (ISO) | No       |                  |
| `finishDate` | `String` (ISO) | No       |                  |
| `finished`   | `Boolean`      | No       | Default: `false` |

**Step type discriminator values:**

| Type string         | Concrete class      |
|---------------------|---------------------|
| `"placeholder"`     | PlaceholderStep     |
| `"stop"`            | Stop                |
| `"hosting"`         | Hosting             |
| `"travel_segment"`  | TravelSegment       |

#### 1.4.1 PlaceholderStep (`type: "placeholder"`)

> A step with no concrete type yet. Used as a draft slot.

Extra fields beyond base:

| JSON Field    | Type     | Nullable |
|---------------|----------|----------|
| `description` | `String` | No       |

#### 1.4.2 Stop (`type: "stop"`)

> A visit to a specific place.

Extra fields beyond base:

| JSON Field    | Type       | Nullable |
|---------------|------------|----------|
| `name`        | `String`   | No       |
| `description` | `String`   | No       |
| `experiences` | `String[]` | No       |

#### 1.4.3 Hosting (`type: "hosting"`)

> An accommodation/hotel stay.

Extra fields beyond base:

| JSON Field | Type           | Nullable |
|------------|----------------|----------|
| `name`     | `String`       | No       |
| `address`  | `String`       | No       |
| `checkIn`  | `String` (ISO) | No       |
| `checkOut` | `String` (ISO) | No       |

#### 1.4.4 TravelSegment (`type: "travel_segment"`)

> A displacement between two points using a transport.

Extra fields beyond base:

| JSON Field    | Type        | Nullable |
|---------------|-------------|----------|
| `startPoint`  | `String`    | No       |
| `finishPoint` | `String`    | No       |
| `transport`   | `Transport` | No       | Full nested transport object |

---

### 1.5 Transport (Polymorphic)

Nested inside `TravelSegment`. Has a `"type"` discriminator.

All transport types share:

| JSON Field | Type           | Nullable | Notes            |
|------------|----------------|----------|------------------|
| `id`       | `String`       | Yes      | Null on creation |
| `type`     | `String` (enum)| No       | Discriminator    |

**Transport type discriminator values:**

| Type string     | Concrete class      |
|-----------------|---------------------|
| `"placeholder"` | PlaceholderTransport|
| `"rental_car"`  | RentalCar           |
| `"bus"`         | Bus                 |
| `"airplane"`    | Airplane            |

#### 1.5.1 PlaceholderTransport (`type: "placeholder"`)

Extra fields:

| JSON Field    | Type     | Nullable |
|---------------|----------|----------|
| `description` | `String` | No       |

#### 1.5.2 RentalCar (`type: "rental_car"`)

Extra fields:

| JSON Field            | Type           | Nullable |
|-----------------------|----------------|----------|
| `vehicleModelName`    | `String`       | No       |
| `vehicleLicensePlate` | `String`       | No       |
| `companyName`         | `String`       | No       |
| `checkInDate`         | `String` (ISO) | No       |
| `checkOutDate`        | `String` (ISO) | No       |

#### 1.5.3 Bus (`type: "bus"`)

Extra fields:

| JSON Field          | Type           | Nullable |
|---------------------|----------------|----------|
| `travelNumber`      | `String`       | No       |
| `travelCompany`     | `String`       | No       |
| `departureGate`     | `String`       | No       |
| `departureDateTime` | `String` (ISO) | No       |
| `busStationName`    | `String`       | No       |
| `description`       | `String`       | No       |
| `details`           | `String`       | Yes      |

#### 1.5.4 Airplane (`type: "airplane"`)

Extra fields:

| JSON Field         | Type           | Nullable |
|--------------------|----------------|----------|
| `flightNumber`     | `String`       | No       |
| `companyName`      | `String`       | No       |
| `flightDate`       | `String` (ISO) | No       |
| `departureGate`    | `String`       | No       |
| `departureAirport` | `String`       | No       |
| `arrivalAirport`   | `String`       | No       |

---

### 1.6 Person

Nested inside `Travel.participants`.

| JSON Field | Type     | Nullable | Notes            |
|------------|----------|----------|------------------|
| `id`       | `String` | Yes      | Null on creation |
| `name`     | `String` | No       |                  |
| `age`      | `String` | No       | Stored as String |
| `sex`      | `String` | No       |                  |

---

### 1.7 TravelEvent

Nested inside `Travel.events`. Events are log entries created when something happens during the travel.

| JSON Field           | Type           | Nullable | Notes                      |
|----------------------|----------------|----------|----------------------------|
| `id`                 | `String`       | Yes      | Null on creation           |
| `eventType`          | `String` (enum)| No       | See TravelEventType values |
| `eventDate`          | `String` (ISO) | No       |                            |
| `eventDescription`   | `String`       | No       |                            |

**TravelEventType enum values (API strings):**

| API String                    |
|-------------------------------|
| `"travel_started"`            |
| `"travel_finished"`           |
| `"step_completed"`            |
| `"step_skipped"`              |
| `"hosting_check_in_completed"`|
| `"hosting_check_out_completed"`|
| `"transport_started"`         |
| `"transport_completed"`       |
| `"transport_delayed"`         |
| `"transport_cancelled"`       |

---

## 2. Required API Endpoints

### Architecture Decision: Why Travel CRUD + Itinerary upsert?

The client sends and receives `Travel` as a **single nested object** (Travel contains RoutePlan,
Itinerary, Participants and Events all together). However, splitting itinerary into its own
endpoint is necessary because:

- The `ItineraryBuildPage` knows only the `travelId` and the itinerary being built.
- An upcoming **autosave** feature will save the itinerary frequently during editing.
- Sending the full `Travel` on every autosave would be wasteful and risks overwriting
  unrelated data (route, participants, events).

### 2.1 Travel CRUD

```
POST   /travels          → Create a new Travel (returns full Travel with assigned IDs)
GET    /travels/{id}     → Get a Travel by ID (returns full nested Travel)
PUT    /travels/{id}     → Full update of a Travel (replaces all nested data)
DELETE /travels/{id}     → Delete a Travel
```

**Notes:**
- `POST` and `PUT` receive the full `Travel` JSON and return the saved object with all IDs populated.
- On `POST`, all nested `id` fields will be `null` — the backend assigns them.
- On `PUT`, preserve existing IDs for nested objects when provided.

### 2.2 Itinerary Upsert (for autosave)

```
PUT /travels/{travelId}/itinerary → Create or fully replace the Itinerary on a Travel
```

**Request body:** Full `Itinerary` JSON (including all steps and transports).

**Response:** The saved `Itinerary` with all IDs populated.

**Behavior:**
- If the Travel has no itinerary yet → create and attach it, update `travelStatus` to `"itinerary_created"`.
- If the Travel already has an itinerary → fully replace it (steps are rebuilt from the payload).
- All nested `id` fields in steps/transports: if null → assign new ID; if present → reuse it.

---

## 3. Full Example Payload

### POST /travels — Request Body

```json
{
  "id": null,
  "clientName": "Maria Silva",
  "travelName": "Lisbon 2025",
  "travelStatus": "route_created",
  "routePlan": {
    "id": null,
    "startDate": "2025-08-01T00:00:00.000Z",
    "finishDate": "2025-08-15T00:00:00.000Z",
    "startLocation": "São Paulo",
    "destination": "Lisbon",
    "interestPoints": [
      {
        "id": null,
        "name": "Belém Tower",
        "description": "Historic tower by the Tagus river"
      }
    ]
  },
  "itinerary": null,
  "participants": [
    {
      "id": null,
      "name": "Maria Silva",
      "age": "34",
      "sex": "F"
    }
  ],
  "events": null
}
```

### PUT /travels/{travelId}/itinerary — Request Body

```json
{
  "id": null,
  "agentName": "Carlos Agent",
  "steps": [
    {
      "id": null,
      "type": "travel_segment",
      "title": "Flight to Lisbon",
      "startDate": "2025-08-01T10:00:00.000Z",
      "finishDate": "2025-08-01T22:00:00.000Z",
      "finished": false,
      "startPoint": "GRU - São Paulo",
      "finishPoint": "LIS - Lisbon",
      "transport": {
        "id": null,
        "type": "airplane",
        "flightNumber": "TP045",
        "companyName": "TAP Air Portugal",
        "flightDate": "2025-08-01T10:00:00.000Z",
        "departureGate": "A12",
        "departureAirport": "GRU",
        "arrivalAirport": "LIS"
      }
    },
    {
      "id": null,
      "type": "hosting",
      "title": "Hotel Avenida",
      "startDate": "2025-08-01T23:00:00.000Z",
      "finishDate": "2025-08-10T12:00:00.000Z",
      "finished": false,
      "name": "Hotel Avenida Palace",
      "address": "Rua 1 de Dezembro 123, Lisbon",
      "checkIn": "2025-08-01T15:00:00.000Z",
      "checkOut": "2025-08-10T12:00:00.000Z"
    },
    {
      "id": null,
      "type": "stop",
      "title": "Visit Belém Tower",
      "startDate": "2025-08-03T09:00:00.000Z",
      "finishDate": "2025-08-03T12:00:00.000Z",
      "finished": false,
      "name": "Belém Tower",
      "description": "UNESCO World Heritage Site",
      "experiences": ["photography", "sightseeing"]
    }
  ]
}
```
