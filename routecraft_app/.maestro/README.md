# Maestro flows — RouteCraft (Android)

Flows executed by the QA (Claude) skill (`jira-qa-executor`) against the
`QA_-_Claude` AVD. Maintained by that skill — see
`.claude/skills/jira-qa-executor` (or the shared `workflow-development-flow`
skill) for the process these flows are part of.

## Structure

```
.maestro/
├── common/
│   └── login_as_joao.yaml       ← shared subflow, called via `runFlow`
├── home/
│   └── travels_grouped_by_status.yaml   (CPS-88)
├── itinerary/
│   ├── today_focused_step.yaml          (CPS-93)
│   └── free_time_and_step_detail.yaml   (CPS-91 / CPS-92)
└── account/
    └── account_page_and_notifications.yaml (CPS-95)
```

A flow here is a **permanent regression asset**, reused across QA rounds —
different from one-off manual exploration done via `adb`/screenshots during
an active QA session. Before adding a new flow, check whether an existing one
already covers the scenario.

## Running

```bash
maestro test .maestro/                          # everything
maestro test .maestro/home/travels_grouped_by_status.yaml   # one flow
```

Requires the `QA_-_Claude` AVD booted (`emulator -avd QA_-_Claude`), the
debug APK installed (`flutter build apk --debug` + `adb install -r`), the
`compass-api` backend reachable (`adb reverse tcp:8081 tcp:8081`), and the QA
fixture data below already seeded.

## QA fixture data this trip relies on

Seeded directly in the local `compass-api` Postgres (`compass_backend` /
`compass_postgres` docker containers) — there is no product flow to create
some of these states (`travel_started`/`travel_finished` have no backend
endpoint; see CPS-93's own description), so direct seeding is the accepted
setup path for this QA environment, not a workaround.

* **Client:** `joao.teste@teste.com` — password resets to `compass123` via
  `POST /users/{id}/reset-password` (requires an agent bearer token; see the
  `qa.agent@compass.test` account, or register a new agent via
  `POST /api/auth/cadastrar/agente`).
* **Travels** (all under "Joao Teste"):
  * `QA Trip CPS-89` — Sao Paulo → Tokyo, **starts the day this fixture was
    seeded** (`travel_status = travel_started`), with a full itinerary
    (`Maria Agente`) covering all itinerary step/transport subtypes: airplane
    (`Flight to Tokyo`), hosting spanning the whole trip (`Shinjuku Granbell
    Hotel`), a stop (`Senso-ji Temple`), a placeholder (`Day trip - TBD`), a
    bus (`Bus to Kyoto`) and a rental car (`Rental car pickup`).
  * `QA Trip Two` — Rio de Janeiro → Paris, `route_created` (no itinerary
    yet) — the "Awaiting agent" / upcoming-without-itinerary case.
  * `QA Trip Finished` — Sao Paulo → Rio de Janeiro, `travel_status =
    travel_finished`, past dates — the completed-section case.

**Known caveat:** `QA Trip CPS-89`'s dates are absolute (fixed at the time of
seeding). `itinerary/today_focused_step.yaml` depends on "today" (whenever
the flow runs) falling within that trip's date range — outside that window
the trip falls back to the read-only Hub page instead of the "Today" view,
and the flow will fail. Re-seed `route_plan.start_date`/`finish_date` (and
the itinerary steps' dates relative to it) to a fresh window spanning
"today" before relying on that flow again. The other flows do not depend on
the current date.

## Known open defects surfaced by these flows

* **CPS-92** — `Bus`'s "Gate" info tile in `StepDetailSheet` always renders
  even when `departureGate` is empty, showing a label with no value under it
  (violates the "no field shown as an empty label" acceptance criterion).
  See the comment in `free_time_and_step_detail.yaml` and
  `step_detail_sheet.dart` (`_transportTiles`, `Bus` case) — needs the same
  `if (value.isNotEmpty)` guard already used for `Stop`/`PlaceholderStep`'s
  optional fields.
