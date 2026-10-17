#!/usr/bin/env python3
"""Popula a API compass-api com empresa, agente, clientes e viagens de teste,
via HTTP real (POST /api/auth/cadastrar/agente com a chave de bootstrap,
POST /users com o token do agente, POST /travels com o token do cliente,
PUT /travels/{id}/itinerary, PUT /travels/{id}), nunca escrevendo direto no
banco. Roda do zero em um banco recriado. Ver README.md.
"""
import json
import os
import sys
import urllib.error
import urllib.request

BASE_URL = "http://localhost:8081"

# Chave que autoriza criar empresa + agente OWNER (COMPASS_BOOTSTRAP_KEY da API;
# o default do docker-compose é dev-bootstrap-key).
BOOTSTRAP_KEY = os.environ.get("COMPASS_BOOTSTRAP_KEY", "dev-bootstrap-key")

# Agente fundador da empresa de teste — é o mesmo agente fixo de QA usado pelos
# flows Maestro do Travel Matrix (.maestro/travel_matrix/auth/login_qa_agent.yaml).
# O e-mail precisa usar o domínio da empresa.
AGENT = {
    "name": "QA Claude", "email": "qa.claude.cps114@compass.test", "password": "QaClaude123!",
    "company": {"name": "Compass QA", "cnpj": "12345678000199", "domain": "compass.test", "plan": "FREE"},
}

# Nomes de campo em inglês (name/age/gender/phone/password) — o exemplo em
# português do README (nome/idade/sexo/telefone/senha) está desatualizado
# em relação à entidade ClientUser atual, que não tem @JsonProperty nenhum.
CLIENTS = [
    {"name": "Ana Beatriz Souza", "cpf": "11111111111", "age": 29, "gender": "F",
     "phone": "11988880001", "email": "ana.souza@teste.com", "password": "senha123"},
    {"name": "Bruno Carvalho Lima", "cpf": "22222222222", "age": 34, "gender": "M",
     "phone": "11988880002", "email": "bruno.lima@teste.com", "password": "senha123"},
    {"name": "Carla Mendes Rocha", "cpf": "33333333333", "age": 41, "gender": "F",
     "phone": "11988880003", "email": "carla.rocha@teste.com", "password": "senha123"},
    {"name": "Diego Ferreira Alves", "cpf": "44444444444", "age": 25, "gender": "M",
     "phone": "11988880004", "email": "diego.alves@teste.com", "password": "senha123"},
    {"name": "Elisa Martins Pinto", "cpf": "55555555555", "age": 37, "gender": "F",
     "phone": "11988880005", "email": "elisa.pinto@teste.com", "password": "senha123"},
]

# Um roteiro por cliente para cada estado do ciclo de vida — garante os 4
# estados representados e exatamente 1 viagem "em andamento" (travel_started)
# por cliente, como pede a issue.
TRIP_TEMPLATES = [
    {"status": "route_created", "destination": "Gramado - RS", "transport": None},
    {"status": "itinerary_created", "destination": "Lisboa - Portugal", "transport": "airplane"},
    {"status": "travel_started", "destination": "Buenos Aires - Argentina", "transport": "bus"},
    {"status": "travel_finished", "destination": "Foz do Iguaçu - PR", "transport": "rental_car"},
]


def request(method, path, body=None, token=None, headers=None):
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode("utf-8") if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    for name, value in (headers or {}).items():
        req.add_header(name, value)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            if not raw:
                return None
            try:
                return json.loads(raw)
            except ValueError:  # algumas rotas respondem texto puro
                return raw.decode("utf-8", "replace")
    except urllib.error.HTTPError as err:
        return {"__error__": err.code, "__body__": err.read().decode("utf-8", "replace")}


def register_agent():
    result = request("POST", "/api/auth/cadastrar/agente", AGENT,
                     headers={"X-Bootstrap-Key": BOOTSTRAP_KEY})
    if isinstance(result, dict) and result.get("__error__"):
        if result["__error__"] == 400:
            print(f"  (já cadastrado, reaproveitando login) {AGENT['email']}")
        else:
            raise RuntimeError(f"Falha ao cadastrar o agente {AGENT['email']}: {result}")
    else:
        print(f"  agente e empresa registrados: {AGENT['email']}")


def login_agent():
    result = request("POST", "/api/auth/login/agente", {
        "email": AGENT["email"], "password": AGENT["password"],
    })
    if not result or "token" not in result:
        raise RuntimeError(f"Falha ao logar {AGENT['email']}: {result}")
    return result["token"], result["userId"]


def existing_client_emails(agent_token):
    result = request("GET", "/users", token=agent_token)
    if not isinstance(result, dict) or result.get("__error__"):
        raise RuntimeError(f"Falha ao listar clientes: {result}")
    return {c["email"] for c in result["data"]}


def create_client(agent_token, client, known_emails):
    """Cria o cliente pelo agente (nasce na empresa dele); idempotente por e-mail."""
    if client["email"] in known_emails:
        print(f"  (já cadastrado, reaproveitando login) {client['email']}")
        return
    created = request("POST", "/users", {
        "name": client["name"], "cpf": client["cpf"], "sex": client["gender"],
        "phoneNumber": client["phone"], "email": client["email"], "password": client["password"],
    }, token=agent_token)
    if isinstance(created, dict) and created.get("__error__"):
        raise RuntimeError(f"Falha ao cadastrar {client['email']}: {created}")
    # POST /users não grava a idade; PUT /users/{id} grava.
    updated = request("PUT", f"/users/{created['data']['id']}", {"age": client["age"]}, token=agent_token)
    if isinstance(updated, dict) and updated.get("__error__"):
        raise RuntimeError(f"Falha ao gravar a idade de {client['email']}: {updated}")
    print(f"  cliente registrado: {client['email']}")


def login_client(client):
    result = request("POST", "/api/auth/login/cliente", {
        "email": client["email"], "password": client["password"],
    })
    if not result or "token" not in result:
        raise RuntimeError(f"Falha ao logar {client['email']}: {result}")
    return result["token"], result["userId"]


def build_transport(kind):
    if kind == "airplane":
        return {"id": None, "type": "airplane", "flightNumber": "LA3456",
                "companyName": "LATAM", "flightDate": "2026-11-01T08:00:00.000Z",
                "departureGate": "A7", "departureAirport": "GRU", "arrivalAirport": "LIS"}
    if kind == "bus":
        return {"id": None, "type": "bus", "travelNumber": "BR-9012",
                "travelCompany": "Buquebus", "departureGate": "12",
                "departureDateTime": "2026-11-01T22:00:00.000Z",
                "busStationName": "Terminal Tietê", "description": "Ônibus leito",
                "details": None}
    if kind == "rental_car":
        return {"id": None, "type": "rental_car", "vehicleModelName": "Jeep Renegade",
                "vehicleLicensePlate": "ABC1D23", "companyName": "Localiza",
                "checkInDate": "2026-11-01T09:00:00.000Z",
                "checkOutDate": "2026-11-05T09:00:00.000Z"}
    return None


def build_itinerary(transport_kind):
    steps = [
        {"id": None, "type": "hosting", "title": "Hospedagem principal",
         "startDate": "2026-11-01T14:00:00.000Z", "finishDate": "2026-11-05T12:00:00.000Z",
         "finished": False, "name": "Hotel Central", "address": "Rua das Flores, 100",
         "checkIn": "2026-11-01T14:00:00.000Z", "checkOut": "2026-11-05T12:00:00.000Z"},
        {"id": None, "type": "stop", "title": "Passeio guiado",
         "startDate": "2026-11-02T09:00:00.000Z", "finishDate": "2026-11-02T12:00:00.000Z",
         "finished": False, "name": "Centro histórico",
         "description": "Tour a pé pelos pontos turísticos", "experiences": ["fotografia", "gastronomia"]},
    ]
    if transport_kind:
        steps.insert(0, {"id": None, "type": "travel_segment", "title": "Deslocamento de ida",
                          "startDate": "2026-11-01T08:00:00.000Z", "finishDate": "2026-11-01T22:00:00.000Z",
                          "finished": False, "startPoint": "São Paulo",
                          "finishPoint": "Destino", "transport": build_transport(transport_kind)})
    return {"id": None, "agentName": "Agente de Testes", "steps": steps}


def create_trip(token, client_name, client_id, agent_id, template, index):
    travel_name = f"Viagem a {template['destination']}"
    travel = {
        "id": None, "clientName": client_name, "clientId": client_id, "agentId": agent_id,
        "travelName": travel_name, "travelStatus": "route_created",
        "routePlan": {
            "id": None, "startDate": "2026-11-01T00:00:00.000Z",
            "finishDate": "2026-11-05T00:00:00.000Z", "startLocation": "São Paulo - SP",
            "destination": template["destination"],
            "interestPoints": [{"id": None, "name": "Ponto turístico principal",
                                 "description": "Atração mais visitada do destino"}],
        },
        "itinerary": None,
        "participants": [{"id": None, "name": client_name, "age": "30", "sex": "F"}],
        "events": None,
    }
    created = request("POST", "/travels", travel, token=token)
    if isinstance(created, dict) and created.get("__error__"):
        raise RuntimeError(f"Falha ao criar viagem {index} de {client_name}: {created}")
    travel_id = created["id"]

    target_status = template["status"]
    if target_status == "route_created":
        print(f"  viagem {index} ({target_status}): {travel_id}")
        return

    itinerary = build_itinerary(template["transport"])
    itinerary_result = request("PUT", f"/travels/{travel_id}/itinerary", itinerary, token=token)
    if isinstance(itinerary_result, dict) and itinerary_result.get("__error__"):
        raise RuntimeError(f"Falha ao anexar itinerário à viagem {travel_id}: {itinerary_result}")

    if target_status != "itinerary_created":
        full_travel = request("GET", f"/travels/{travel_id}", token=token)
        if isinstance(full_travel, dict) and full_travel.get("__error__"):
            raise RuntimeError(f"Falha ao buscar viagem {travel_id}: {full_travel}")
        full_travel["travelStatus"] = target_status
        status_result = request("PUT", f"/travels/{travel_id}", full_travel, token=token)
        if isinstance(status_result, dict) and status_result.get("__error__"):
            raise RuntimeError(f"Falha ao atualizar status da viagem {travel_id}: {status_result}")

    print(f"  viagem {index} ({target_status}): {travel_id}")


def main():
    print(f"Populando {BASE_URL} com {len(CLIENTS)} clientes e "
          f"{len(CLIENTS) * len(TRIP_TEMPLATES)} viagens...")
    print("\nEmpresa e agente:")
    register_agent()
    agent_token, agent_id = login_agent()
    known_emails = existing_client_emails(agent_token)
    for client in CLIENTS:
        print(f"\n{client['name']}:")
        create_client(agent_token, client, known_emails)
        token, client_id = login_client(client)
        for i, template in enumerate(TRIP_TEMPLATES, start=1):
            # Viagem criada com o token do cliente: a empresa vem do cliente.
            create_trip(token, client["name"], client_id, agent_id, template, i)
    print("\nConcluído.")


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as exc:
        print(f"\nErro: {exc}", file=sys.stderr)
        sys.exit(1)
