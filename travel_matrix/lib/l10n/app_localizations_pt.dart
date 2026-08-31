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
  String get forgotPasswordLink => 'Esqueceu a senha?';

  @override
  String get forgotPasswordTitle => 'Redefinir sua senha';

  @override
  String get forgotPasswordSubtitle =>
      'Informe seu e-mail e enviaremos um código para redefinir sua senha.';

  @override
  String get forgotPasswordSubmitButton => 'ENVIAR CÓDIGO';

  @override
  String get forgotPasswordConfirmation =>
      'Se este e-mail estiver cadastrado, você receberá um código para redefinir sua senha.';

  @override
  String get resetPasswordTitle => 'Informe o código';

  @override
  String get resetPasswordSubtitle =>
      'Informe o código recebido por e-mail e escolha uma nova senha.';

  @override
  String get resetPasswordTokenLabel => 'Código';

  @override
  String get resetPasswordTokenRequired => 'Informe o código';

  @override
  String get resetPasswordNewPasswordLabel => 'Nova senha';

  @override
  String get resetPasswordNewPasswordRequired => 'Informe uma nova senha';

  @override
  String get resetPasswordSubmitButton => 'REDEFINIR SENHA';

  @override
  String get resetPasswordSuccess =>
      'Senha redefinida com sucesso. Você já pode fazer login.';

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
  String get failedToLoadDashboard =>
      'Não foi possível carregar seu painel agora. Tente novamente mais tarde.';

  @override
  String get statusComplete => 'COMPLETO';

  @override
  String get statusPending => 'PENDENTE';

  @override
  String get failedToLoadTravels =>
      'Não foi possível carregar as viagens agora. Tente novamente mais tarde.';

  @override
  String get allTravels => 'Todas as Viagens';

  @override
  String get createTravel => 'Criar Viagem';

  @override
  String get itineraryReady => 'Roteiro Pronto';

  @override
  String get routeOnly => 'Apenas Rota';

  @override
  String get travelInProgress => 'Em Andamento';

  @override
  String get travelCompleted => 'Concluída';

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
  String get failedToLoadProfile =>
      'Não foi possível carregar seu perfil agora. Tente novamente mais tarde.';

  @override
  String get currentPassword => 'Senha Atual';

  @override
  String get newPassword => 'Nova Senha';

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
  String get clientUsersTitle => 'Usuários Clientes';

  @override
  String get searchUsersHint => 'Buscar usuários...';

  @override
  String get activeStatusLabel => 'Ativo';

  @override
  String get inactiveStatusLabel => 'Inativo';

  @override
  String get noClientUsersFoundMessage => 'Nenhum usuário cliente encontrado.';

  @override
  String get failedToLoadUsers =>
      'Não foi possível carregar os usuários agora. Tente novamente mais tarde.';

  @override
  String get backToUsersButton => 'Voltar para Usuários';

  @override
  String get maleGenderLabel => 'Masculino';

  @override
  String get femaleGenderLabel => 'Feminino';

  @override
  String get otherOptionLabel => 'Outro';

  @override
  String get travelHistoryTitle => 'Histórico de Viagens';

  @override
  String get noTravelsForUserMessage =>
      'Nenhuma viagem encontrada para este usuário.';

  @override
  String get securityActionsTitle => 'Ações de Segurança';

  @override
  String get resetPasswordActionTitle => 'Redefinir Senha';

  @override
  String get resetPasswordActionDescription =>
      'Envia um link para o e-mail do usuário redefinir a senha com segurança.';

  @override
  String get forceLogoutActionTitle => 'Forçar Logout';

  @override
  String get forceLogoutActionDescription =>
      'Encerra imediatamente todas as sessões ativas deste usuário.';

  @override
  String get resetPasswordSuccessMessage =>
      'Link de redefinição de senha enviado';

  @override
  String get resetPasswordFailureMessage =>
      'Falha ao enviar link de redefinição';

  @override
  String get forceLogoutSuccessMessage => 'Sessões do usuário encerradas';

  @override
  String get forceLogoutFailureMessage => 'Falha ao encerrar sessões';

  @override
  String get travelStatsTitle => 'Estatísticas de Viagem';

  @override
  String get uniqueDestinationsStatLabel => 'DESTINOS ÚNICOS';

  @override
  String get forceLogoutConfirmTitle => 'Forçar Logout?';

  @override
  String get forceLogoutConfirmMessage =>
      'Isso encerrará imediatamente todas as sessões ativas deste usuário. Continuar?';

  @override
  String get confirmActionButton => 'CONFIRMAR';

  @override
  String get cancelActionButton => 'CANCELAR';

  @override
  String get newClientUserFormTitle => 'Novo Usuário Cliente';

  @override
  String get fullNameFieldLabel => 'Nome Completo';

  @override
  String get nameRequiredValidation => 'Nome é obrigatório';

  @override
  String get cpfRequiredValidation => 'CPF é obrigatório';

  @override
  String get emailRequiredValidation => 'Email é obrigatório';

  @override
  String get phoneNumberFieldLabel => 'Número de Telefone';

  @override
  String get phoneRequiredValidation => 'Telefone é obrigatório';

  @override
  String get initialPasswordFieldLabel => 'Senha Inicial';

  @override
  String get passwordRequiredValidation => 'Senha é obrigatória';

  @override
  String get sexFieldLabel => 'Sexo';

  @override
  String get birthDateFieldLabel => 'Data de Nascimento';

  @override
  String get createUserSubmitButton => 'CRIAR USUÁRIO';

  @override
  String editUserPageSubtitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get saveChangesButton => 'SALVAR ALTERAÇÕES';

  @override
  String get deactivateUserDialogTitle => 'Desativar Usuário';

  @override
  String deactivateReasonPrompt(String name) {
    return 'Por que você está desativando $name?';
  }

  @override
  String get deactivateReasonClientRequest => 'Solicitação do cliente';

  @override
  String get deactivateReasonNonPayment => 'Inadimplência';

  @override
  String get deactivateReasonTermsViolation => 'Violação de termos de uso';

  @override
  String get deactivateReasonDuplicateAccount => 'Conta duplicada';

  @override
  String get specifyReasonFieldLabel => 'Especifique o motivo';

  @override
  String get deactivateButtonCaps => 'DESATIVAR';

  @override
  String get userNotFoundTitle => 'Usuário Não Encontrado';

  @override
  String get userNotFoundMessage =>
      'O usuário solicitado não pôde ser encontrado.';

  @override
  String get buildItineraryTitle => 'Montar Roteiro';

  @override
  String get cannotMoveStep =>
      'Não é possível mover esta etapa para essa posição.';

  @override
  String get cannotDeleteStepMessage => 'Não é possível excluir esta etapa.';

  @override
  String get itineraryUpdatedSuccess => 'Roteiro atualizado.';

  @override
  String get itineraryCreatedSuccess => 'Roteiro criado.';

  @override
  String get couldNotSaveItinerary => 'Não foi possível salvar o roteiro.';

  @override
  String get editRouteTitle => 'Editar Rota';

  @override
  String get updateRouteButton => 'ATUALIZAR ROTA';

  @override
  String get createTravelButton => 'CRIAR VIAGEM';

  @override
  String get editRoutePlanButton => 'Editar Plano de Rota';

  @override
  String get markAsReadyButton => 'Marcar como Pronta';

  @override
  String get markAsReadyConfirm =>
      'Tem certeza que deseja marcar esta viagem como pronta?';

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get markAsReadySuccess => 'Viagem marcada como pronta com sucesso';

  @override
  String get markAsReadyFailure => 'Falha ao marcar viagem como pronta';

  @override
  String get needsItineraryFirstTooltip =>
      'Você precisa criar um roteiro primeiro';

  @override
  String get markAsReadyTooltip => 'Marcar viagem como pronta';

  @override
  String get routeViewTab => 'Ver Rota';

  @override
  String get itineraryViewTab => 'Ver Roteiro';

  @override
  String travelersCount(int count) {
    return '$count Viajantes';
  }

  @override
  String get travelNotFoundTitle => 'Viagem Não Encontrada';

  @override
  String get travelNotFoundBody =>
      'A viagem solicitada não pôde ser encontrada.';

  @override
  String get changeStepTypeTitle => 'Alterar Tipo de Etapa?';

  @override
  String get changeStepTypeBody =>
      'Alterar o tipo da etapa resultará na perda dos dados específicos inseridos para a etapa atual. Deseja continuar?';

  @override
  String get changeTransportTypeTitle => 'Alterar Tipo de Transporte?';

  @override
  String get changeTransportTypeBody =>
      'Alterar o tipo de transporte resultará na perda dos dados específicos inseridos para o transporte atual. Deseja continuar?';

  @override
  String get proceedButton => 'Continuar';

  @override
  String get noStepsYet => 'Nenhuma etapa ainda';

  @override
  String get noItineraryAvailable => 'Nenhum roteiro disponível.';

  @override
  String get stepDetailsUnavailable =>
      'Detalhes adicionais desta etapa ainda não estão disponíveis.';

  @override
  String get draftStepTitle => 'Etapa Rascunho';

  @override
  String get unknownStepTitle => 'Etapa Desconhecida';

  @override
  String get noItineraryYetTitle => 'Ainda Sem Roteiro';

  @override
  String stepsCountLabel(int count) {
    return 'Etapas ($count)';
  }

  @override
  String get noInterestPointsPanel => 'Nenhum ponto de interesse';

  @override
  String get selectDateTooltip => 'Selecionar data';

  @override
  String get addInterestPointTooltip => 'Adicionar ponto de interesse';

  @override
  String get removeInterestPointTooltip => 'Remover ponto de interesse';

  @override
  String get addExperienceTooltip => 'Adicionar experiência';
}
