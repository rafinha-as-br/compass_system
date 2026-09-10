#!/usr/bin/env python3
"""Self-check das funções puras de seed_test_data.py (sem rede — não sobe a
API). Rode com: python test_seed_test_data.py
"""
from seed_test_data import CLIENTS, TRIP_TEMPLATES, build_itinerary, build_transport


def test_build_transport_covers_all_kinds():
    for kind in ["airplane", "bus", "rental_car"]:
        transport = build_transport(kind)
        assert transport["type"] == kind, f"transport type mismatch para {kind}"
        assert transport["id"] is None

    assert build_transport(None) is None


def test_build_itinerary_has_steps_of_varied_types():
    itinerary_com_transporte = build_itinerary("airplane")
    types = [s["type"] for s in itinerary_com_transporte["steps"]]
    assert "travel_segment" in types
    assert "hosting" in types
    assert "stop" in types
    assert len(types) == len(set(types)), "esperado tipos de passo variados, sem repetição"

    itinerary_sem_transporte = build_itinerary(None)
    assert "travel_segment" not in [s["type"] for s in itinerary_sem_transporte["steps"]]


def test_lifecycle_coverage_and_one_in_progress_per_client():
    statuses = [t["status"] for t in TRIP_TEMPLATES]
    assert set(statuses) == {"route_created", "itinerary_created", "travel_started", "travel_finished"}
    assert statuses.count("travel_started") == 1, "esperado exatamente 1 viagem em andamento por cliente"


def test_at_least_a_few_clients_with_unique_emails():
    assert len(CLIENTS) >= 3
    emails = [c["email"] for c in CLIENTS]
    assert len(emails) == len(set(emails)), "e-mails de clientes duplicados"
    for c in CLIENTS:
        assert set(c) == {"name", "cpf", "age", "gender", "phone", "email", "password"}


if __name__ == "__main__":
    tests = [v for k, v in list(globals().items()) if k.startswith("test_")]
    for test in tests:
        test()
        print(f"ok: {test.__name__}")
    print(f"\n{len(tests)} testes passaram.")
