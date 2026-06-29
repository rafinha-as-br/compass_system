# Travel Matrix

**Travel Matrix** é a aplicação administrativa do Compass System desenvolvida em Flutter, voltada exclusivamente para os **agentes de viagem**. Ela fornece uma interface para gerenciar clientes, acompanhar o status das viagens e criar/atualizar itinerários de forma detalhada.

## 🏗 Arquitetura do Projeto

O projeto segue uma arquitetura modular orientada a **Features** (Feature-First), visando a separação de responsabilidades, escalabilidade e manutenibilidade.

### Estrutura de Diretórios Principal

A base de código em `lib/` está dividida nas seguintes camadas principais:

- **`app/`**: Configurações globais, ponto de entrada da aplicação (`main.dart`), definições de temas e inicialização das rotas.
- **`core/`**: Módulos fundamentais do sistema, utilitários, tratamento de erros, clientes HTTP e configurações transversais.
- **`features/`**: Módulos funcionais da aplicação (ex: `auth`, `home`, `travel_management`). Cada feature é autocontida e abriga suas próprias telas, widgets específicos, gerenciamento de estado e regras de negócio/serviços.
- **`shared/`**: Componentes visuais reutilizáveis (design system interno), como botões padrões, inputs, diálogos e outros utilitários compartilhados entre várias features.

## 📐 Padrões e Decisões Técnicas

- **Navegação (`go_router`)**: 
  - A navegação é estruturada de forma declarativa utilizando o `go_router`.
  - Faz uso de `ShellRoute` (Stateful Shell) para implementar navegação persistente com bottom navigation/sidebars (ex: Dashboard do agente).
  - Controle de fluxo e redirecionamento automáticos dependendo do estado de autenticação do usuário.

- **Gerenciamento de Estado (`Provider`)**:
  - Utilizado para injeção de dependência e controle de estado reativo.
  - As telas escutam as mudanças de estado dos *controllers/viewmodels* e reagem a elas.
  - A lógica visual é estritamente separada das regras de negócio (Controllers conversam com Services).

- **Autenticação e Segurança**:
  - O sistema é restrito para usuários onde `userType` seja igual a `AGENTE`.
  - A persistência local do token de autenticação JWT é feita usando `shared_preferences`.

- **Integração Backend**:
  - O aplicativo se comunica de forma centralizada com a **Compass API**.
  - Chamadas protegidas incluem automaticamente o cabeçalho `Authorization: Bearer <token>`.

## 📜 Regras de Desenvolvimento Interno

Para manter o código limpo e coeso, seguimos princípios rígidos na arquitetura:
1. **MVP e Simplicidade em 1º Lugar**: Evitar over-engineering. Preferir soluções diretas e legíveis.
2. **Isolamento da UI**: *Widgets* e *Screens* não devem conter regras de negócio, apenas composição visual e interações primárias.
3. **Serviços Focados**: Camadas de serviço (`Services`) não podem ter qualquer conhecimento sobre elementos visuais ou Widgets do Flutter.

## ⚙️ Como Executar

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install)

### Passo a Passo
Na raiz do diretório `travel_matrix`:

1. Instale as dependências do projeto:
   ```bash
   flutter pub get
   ```

2. Execute o aplicativo:
   ```bash
   flutter run
   ```
