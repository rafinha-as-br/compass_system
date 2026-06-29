# Compass System — Backend

API RESTful para a plataforma de planejamento de viagens Compass System, desenvolvida em **Java (Spring Boot)** com banco de dados **PostgreSQL** e suporte a **Docker/Docker Compose**.

---

## 🚀 Como Rodar o Projeto Localmente

### Pré-requisitos
*   [Docker](https://www.docker.com/products/docker-desktop) instalado e rodando.

### Inicialização Rápida
1.  Na pasta raiz do projeto (onde está o arquivo `docker-compose.yml`), execute o comando para iniciar o banco de dados PostgreSQL e compilar/rodar a API automaticamente:
    ```bash
    docker-compose up -d --build
    ```
2.  A API estará disponível no endereço: **`http://localhost:8081`**

### Rodando Testes Automatizados
O projeto conta com testes de integração cobrindo todo o ciclo do CRUD. Eles rodam usando um banco em memória (H2), dispensando a necessidade do Postgres estar ativo. Para executá-los:
```bash
./mvnw test
```

---

## 🔌 Endpoints da API

A URL base da API é **`http://localhost:8081`**. 

> 🔓 **CORS**: Habilitado para todas as origens (`*`). O app front-end (Flutter/Web) não sofrerá bloqueios de navegação.

### 🔑 Autenticação de Clientes (`/api/auth`)

*   **Cadastro de Cliente**
    *   **Método:** `POST`
    *   **Rota:** `/api/auth/cadastrar/cliente`
    *   **Corpo da Requisição (JSON):**
        ```json
        {
          "nome": "Maria Silva",
          "cpf": "12345678909",
          "idade": 34,
          "sexo": "F",
          "telefone": "11988887777",
          "email": "maria@email.com",
          "senha": "senha_segura"
        }
        ```

*   **Login de Cliente**
    *   **Método:** `POST`
    *   **Rota:** `/api/auth/login/cliente`
    *   **Corpo da Requisição (JSON):**
        ```json
        {
          "email": "maria@email.com",
          "senha": "senha_segura"
        }
        ```

---

### ✈️ Gerenciamento de Viagens (`/travels`)

Controlador que gerencia as viagens agrupadas de ponta a ponta. 

#### 1. Criar Viagem
*   **Método:** `POST`
*   **Rota:** `/travels`
*   **Objetivo:** Cria uma nova viagem (geralmente enviando a rota base e participantes inicializados).
*   **Regra de ID:** Envie os campos `id` como `null`. O backend gerará UUIDs automaticamente e os retornará no JSON de resposta.

#### 2. Buscar Viagem por ID
*   **Método:** `GET`
*   **Rota:** `/travels/{id}`
*   **Objetivo:** Retorna todo o grafo aninhado da viagem (rota, itinerário, participantes e logs de eventos).

#### 3. Atualizar Viagem Completa
*   **Método:** `PUT`
*   **Rota:** `/travels/{id}`
*   **Objetivo:** Sobrescreve toda a viagem com o novo JSON enviado. Útil quando são adicionados participantes, alterados pontos de interesse na rota, etc. 
*   **Regra de ID:** Se você enviar objetos filhos com um `id` válido, o backend irá atualizá-los. Se o `id` de um filho for `null`, um novo ID será gerado.

#### 4. Excluir Viagem
*   **Método:** `DELETE`
*   **Rota:** `/travels/{id}`
*   **Objetivo:** Apaga a viagem e realiza a exclusão em cascata de todas as entidades associadas (itinerários, rotas, etc.).

#### 5. Salvar/Atualizar Itinerário (Autosave)
*   **Método:** `PUT`
*   **Rota:** `/travels/{travelId}/itinerary`
*   **Objetivo:** Cria ou substitui apenas o itinerário da viagem. Útil para o autosave durante o fluxo de edição de passos sem precisar trafegar os dados completos da viagem.
*   **Efeito Colateral:** Quando um itinerário é associado à viagem pela primeira vez, o status da viagem (`travelStatus`) muda automaticamente de `"route_created"` para `"itinerary_created"`.

---

## 💡 Guia de Integração para o Front-end (Flutter / HTTP Client)

### 📌 1. Regra de IDs (`domainId` vs `id`)
*   **`domainId` é apenas local no cliente**: Nunca envie ou espere receber o campo `domainId`.
*   **`id` (ou `backEndId`) é o ID real**: O backend usa apenas a chave `id` para mapear os registros em banco. 
*   Ao criar uma viagem ou qualquer item novo em listas aninhadas, envie `"id": null`. O servidor responderá com o ID UUID preenchido (ex: `"abc-123-xyz"`).

### 📌 2. Formato de Datas
Todas as datas devem ser transmitidas em strings ISO 8601 contendo fuso horário UTC (ex: `"2025-08-01T10:00:00.000Z"`).

### 📌 3. Polimorfismo nos Passos do Itinerário (`type`)
Os passos da lista `steps` dentro do itinerário exigem a tag `"type"` como discriminador para o backend identificar a estrutura de dados correta:

| Valor de `"type"` | Tipo de Classe | Campos Adicionais no JSON |
|---|---|---|
| `"placeholder"` | Rascunho de Passo | `description` |
| `"stop"` | Parada/Visita | `name`, `description`, `experiences` (lista de strings) |
| `"hosting"` | Hospedagem | `name`, `address`, `checkIn` (data), `checkOut` (data) |
| `"travel_segment"` | Trecho/Deslocamento | `startPoint`, `finishPoint`, `transport` (objeto aninhado) |

#### Exemplo de Payload para `PUT /travels/{travelId}/itinerary`:
```json
{
  "id": null,
  "agentName": "Carlos Agente",
  "steps": [
    {
      "id": null,
      "type": "travel_segment",
      "title": "Voo para Lisboa",
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
      "type": "stop",
      "title": "Visita à Torre de Belém",
      "startDate": "2025-08-03T09:00:00.000Z",
      "finishDate": "2025-08-03T12:00:00.000Z",
      "finished": false,
      "name": "Torre de Belém",
      "description": "Patrimônio Mundial da UNESCO",
      "experiences": ["fotografia", "turismo"]
    }
  ]
}
```

### 📌 4. Polimorfismo de Transportes (`type`)
Quando o passo for `"travel_segment"`, o objeto de transporte (`transport`) também exige o discriminador `"type"` para validar as propriedades internas:

| Valor de `"type"` | Tipo de Transporte | Campos Adicionais no JSON |
|---|---|---|
| `"placeholder"` | Transporte Rascunho | `description` |
| `"rental_car"` | Aluguel de Carro | `vehicleModelName`, `vehicleLicensePlate`, `companyName`, `checkInDate`, `checkOutDate` |
| `"bus"` | Ônibus | `travelNumber`, `travelCompany`, `departureGate`, `departureDateTime`, `busStationName`, `description`, `details` |
| `"airplane"` | Avião | `flightNumber`, `companyName`, `flightDate`, `departureGate`, `departureAirport`, `arrivalAirport` |