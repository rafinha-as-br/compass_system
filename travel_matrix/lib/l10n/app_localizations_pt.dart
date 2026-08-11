// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Travel Matrix';

  @override
  String get loginTitle => 'Bem-vindo ao Travel Matrix';

  @override
  String get loginSubtitle => 'Faça login para continuar';

  @override
  String get loginLabel => 'Acessar o Travel Matrix';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginTitlePanel => 'Login do Agente';

  @override
  String get loginSubtitlePanel => 'Por favor, autentique-se para continuar';

  @override
  String get loginButton => 'ENTRAR COMO AGENTE';

  @override
  String get loginEmailRequired => 'Informe o e-mail';

  @override
  String get loginPasswordRequired => 'Informe a senha';

  @override
  String get loginAccessDenied =>
      'Acesso negado. Apenas Agentes de Viagem podem acessar o Travel Matrix.';

  @override
  String get loginError => 'Ocorreu um erro durante o login.';

  @override
  String get dashboardTitle => 'Visão Geral';

  @override
  String get totalTravels => 'Total de Viagens';

  @override
  String get itinerariesCompleted => 'Roteiros Completos';

  @override
  String get pendingItineraries => 'Roteiros Pendentes';

  @override
  String get activeClients => 'Clientes Ativos';

  @override
  String get recentTravelUpdates => 'Atualizações Recentes';

  @override
  String get noTravelsCreated => 'Nenhuma viagem criada ainda.';

  @override
  String get statusComplete => 'COMPLETO';

  @override
  String get statusPending => 'PENDENTE';

  @override
  String get allTravels => 'Todas as Viagens';

  @override
  String get createTravel => 'Criar Viagem';

  @override
  String get itineraryReady => 'Roteiro Pronto';

  @override
  String get routeOnly => 'Apenas Rota';

  @override
  String get clientLabel => 'Cliente';

  @override
  String get createTravelTitle => 'Criar Viagem';

  @override
  String get stepCreateRoute => 'Passo 1: Criar Rota';

  @override
  String get stepCreateRouteHint =>
      'Defina a rota primeiro. Um roteiro pode ser criado depois.';

  @override
  String get travelNameLabel => 'Nome da Viagem';

  @override
  String get travelNameRequired => 'Nome da viagem é obrigatório';

  @override
  String get startLocationLabel => 'Local de Partida';

  @override
  String get destinationLabel => 'Destino';

  @override
  String get requiredField => 'Obrigatório';

  @override
  String get startDateLabel => 'Data de Início';

  @override
  String get endDateLabel => 'Data de Término';

  @override
  String get interestPointsTitle => 'Pontos de Interesse';

  @override
  String get pointNameLabel => 'Nome do Ponto';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String get createItineraryTitle => 'Criar Roteiro';

  @override
  String get editItineraryTitle => 'Editar Roteiro';

  @override
  String get saveButton => 'Salvar';

  @override
  String get updateButton => 'Atualizar';

  @override
  String get createButton => 'Criar';

  @override
  String get finishItinerary => 'Finalizar Roteiro';

  @override
  String get deleteStep => 'Excluir Etapa';

  @override
  String get deleteStepConfirm => 'Tem certeza que deseja excluir esta etapa?';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Excluir';

  @override
  String get addStep => 'Adicionar Etapa';

  @override
  String get addFirstStepHint =>
      'Adicione sua primeira etapa para começar a construir o roteiro.';

  @override
  String get previousStep => 'Etapa Anterior';

  @override
  String get nextStep => 'Próxima Etapa';

  @override
  String get itinerarySavedSuccess => 'Roteiro salvo.';

  @override
  String get itineraryFinishedSuccess => 'Roteiro finalizado com sucesso!';

  @override
  String get failedToCreateItinerary => 'Falha ao criar roteiro.';

  @override
  String get routeDetails => 'Detalhes da Rota';

  @override
  String get fromLabel => 'De';

  @override
  String get toLabel => 'Para';

  @override
  String interestPointsCount(int count) {
    return 'Pontos de Interesse ($count)';
  }

  @override
  String get noInterestPoints => 'Nenhum ponto de interesse definido.';

  @override
  String get noItineraryCreated => 'Nenhum roteiro foi criado ainda.';

  @override
  String get notAuthenticated => 'Não autenticado.';

  @override
  String failedToFetchTravels(String error) {
    return 'Falha ao buscar viagens: $error';
  }

  @override
  String failedToFetchUsers(String error) {
    return 'Falha ao buscar usuários: $error';
  }

  @override
  String get usersTitle => 'Usuários';

  @override
  String get createUser => 'Criar Usuário';

  @override
  String get editUser => 'Editar Usuário';

  @override
  String get viewUser => 'Ver Usuário';

  @override
  String get deleteUser => 'Excluir Usuário';

  @override
  String get deleteUserConfirm =>
      'Tem certeza que deseja excluir este usuário?';

  @override
  String get agentSettings => 'Configurações do Agente';

  @override
  String get systemPreferences => 'Preferências do Sistema';

  @override
  String get adminDarkMode => 'Modo Escuro Administrativo';

  @override
  String get logOutOfMatrix => 'Sair do Matrix';

  @override
  String get languageLabel => 'Idioma';

  @override
  String dashboardWelcome(String name) {
    return 'Bem-vindo, $name';
  }

  @override
  String dashboardWelcomeSubtitle(int pending, int completed) {
    return 'Sua mesa esta pronta com $pending roteiros pendentes e $completed roteiros completos.';
  }

  @override
  String get recentTravels => 'Viagens Recentes';

  @override
  String get activeClientsListTitle => 'Clientes Ativos';

  @override
  String get travelNameColumn => 'Nome da Viagem';

  @override
  String get clientNameColumn => 'Nome';

  @override
  String get routeColumn => 'Rota';

  @override
  String get statusColumn => 'Status';

  @override
  String get datesColumn => 'Datas';

  @override
  String get actionsColumn => 'Acoes';

  @override
  String get viewTravel => 'Ver Viagem';

  @override
  String get searchTravelsHint => 'Buscar viagens...';

  @override
  String get allStatus => 'Todos os Status';

  @override
  String get profileSection => 'Perfil';

  @override
  String get cpfLabel => 'CPF';

  @override
  String get cnpjLabel => 'CNPJ';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get editAgentData => 'Editar Dados do Agente';

  @override
  String get changePassword => 'Trocar Senha';

  @override
  String get currentPassword => 'Senha Atual';

  @override
  String get newPassword => 'Nova Senha';

  @override
  String get invalidCpf => 'CPF inválido.';

  @override
  String get invalidCnpj => 'CNPJ inválido.';

  @override
  String get invalidEmail => 'E-mail inválido.';

  @override
  String get confirmPasswordRequired =>
      'Confirme sua senha atual para continuar.';

  @override
  String get profileUpdatedSuccess => 'Perfil atualizado com sucesso.';

  @override
  String get digitalConcierge => 'O CONCIERGE DIGITAL';

  @override
  String get dashboardNav => 'Dashboard';

  @override
  String get bookingNav => 'Reservas';

  @override
  String get settingsNav => 'Configuracoes';

  @override
  String get supportNav => 'Suporte';

  @override
  String get logoutNav => 'Sair';

  @override
  String get travelAgentRole => 'Agente de Viagens';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceSection => 'Aparência';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Seguir sistema';

  @override
  String get languageSection => 'Idioma';
}
