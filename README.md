# Compass System

O **Compass System** é uma solução completa de planejamento de viagens projetada para facilitar a comunicação e o processo de organização entre clientes e agentes de viagem.

## 📌 Sobre o Projeto

O sistema permite que o cliente registre sua intenção de viagem (rota) e que o agente de viagens transforme essa rota em um itinerário estruturado. A solução é composta por três módulos principais:

1. **RouteCraft**: Aplicativo móvel (Flutter) para o cliente criar rotas e acompanhar a viagem.
2. **Travel Matrix**: Aplicação administrativa (Flutter) para o agente organizar as viagens e os itinerários.
3. **Compass API**: Backend REST desenvolvido em **Java 17** com **Spring Boot 3.2.4**.

## 🚀 Funcionalidades

### Cliente (RouteCraft)
- Cadastro e login.
- Criação de rotas de viagem, definindo datas, locais e pontos de interesse.
- Visualização e acompanhamento do itinerário da viagem.

### Agente (Travel Matrix)
- Login no ambiente administrativo restrito.
- Gestão de viagens solicitadas pelos clientes.
- Criação e atualização de itinerários passo a passo.

## 🛠 Tecnologias Utilizadas

### Frontend (Apps)
- **Flutter**
- **go_router** / **Provider** (Navegação e Gerenciamento de Estado)
- **flutter_secure_storage** e **shared_preferences** (Persistência segura local)

### Backend (API)
- **Java 17**
- **Spring Boot 3.2.4**
- **PostgreSQL**
- **Spring Security** & **JWT**
- **Hibernate / JPA**

### Infraestrutura
- **Docker** e **Docker Compose**

## 🏗 Estrutura do Repositório

O projeto é organizado nos seguintes módulos principais:
- `/compass-api`: Código-fonte da API backend.
- `/routecraft_app`: Código-fonte do app do cliente.
- `/travel_matrix`: Código-fonte do app do agente.

## ⚙️ Como Executar

### Pré-requisitos
- [Docker](https://www.docker.com/) e Docker Compose
- [Java 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) (ou superior)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)

### Rodando o Backend e Banco de Dados
O projeto utiliza um `docker-compose.yml` para facilitar a inicialização do banco de dados e da API.
1. Na raiz do projeto, execute:
   ```bash
   docker-compose up -d
   ```
2. O banco de dados PostgreSQL estará disponível em `localhost:5432` e a API em `http://localhost:8081`.

*(Nota: Se preferir rodar a API localmente via IDE, basta iniciar apenas o banco no Docker e rodar o projeto Spring Boot normalmente).*

### Rodando o App do Cliente (RouteCraft)
```bash
cd routecraft_app
flutter pub get
flutter run
```

### Rodando o App do Agente (Travel Matrix)
```bash
cd travel_matrix
flutter pub get
flutter run
```

## 🔒 Segurança
- Autenticação via **JWT (JSON Web Token)** stateless.
- Senhas são criptografadas no banco utilizando **BCrypt**.
- Tokens expiram em 24 horas.
- A comunicação entre os apps e a API exige que o token seja enviado no header `Authorization: Bearer <token>`.

## 🤝 Contribuição
(Adicione aqui as regras e padrões de contribuição da equipe, se houver).
