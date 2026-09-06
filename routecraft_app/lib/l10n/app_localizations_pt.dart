// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'RouteCraft';

  @override
  String get appBrandSubtitle => 'Compass System';

  @override
  String get splashCheckingSession => 'Verificando sessão…';

  @override
  String get loginTitle => 'Bem-vindo de volta';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailHint => 'voce@email.com';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginButton => 'ENTRAR';

  @override
  String get loginEmailRequired => 'Informe o e-mail';

  @override
  String get loginPasswordRequired => 'Informe a senha';

  @override
  String get loginAccessDenied =>
      'Acesso negado. Apenas Clientes podem acessar o RouteCraft.';

  @override
  String get loginError => 'Ocorreu um erro durante o login.';

  @override
  String get loginNoAccountFooter => 'Não tem conta? Fale com seu agente';

  @override
  String get loginShowPassword => 'Mostrar senha';

  @override
  String get loginHidePassword => 'Ocultar senha';

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
  String get homeTitle => 'Início RouteCraft';

  @override
  String get createRouteNav => 'Criar uma Rota';

  @override
  String get visualizeRoutesNav => 'Visualizar Rotas e Roteiros';

  @override
  String get accountSettingsNav => 'Conta e Configurações';

  @override
  String homeGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get homeSectionInProgress => 'Em andamento';

  @override
  String get homeSectionUpcoming => 'Próximas';

  @override
  String get homeSectionCompleted => 'Concluídas';

  @override
  String get homeEmptyMessage =>
      'Descreva a viagem que você quer fazer e seu agente monta o roteiro.';

  @override
  String get homeEmptyCta => 'Criar minha primeira rota';

  @override
  String get homeNavLabel => 'Início';

  @override
  String get itineraryNavLabel => 'Roteiro';

  @override
  String get accountNavLabel => 'Conta';

  @override
  String get createRouteTitle => 'Criar uma Rota';

  @override
  String get tripInfoStep => 'Informações da Viagem';

  @override
  String get tripNameLabel => 'Nome da Viagem';

  @override
  String get locationsStep => 'Locais';

  @override
  String get startLocationLabel => 'Local de Partida';

  @override
  String get destinationLabel => 'Destino';

  @override
  String get interestsStep => 'Interesses';

  @override
  String get submitRoute => 'ENVIAR ROTA';

  @override
  String get nextButton => 'PRÓXIMO';

  @override
  String get backButton => 'VOLTAR';

  @override
  String get editButton => 'Editar';

  @override
  String get routeCreatedSuccess => 'Rota criada com sucesso!';

  @override
  String get backToHome => 'Voltar ao Início';

  @override
  String failedToCreateRoute(String error) {
    return 'Falha ao criar rota: $error';
  }

  @override
  String get successTitle => 'Sucesso';

  @override
  String routeCreationStepIndicator(int step, int total) {
    return 'PASSO $step DE $total';
  }

  @override
  String get routeCreationNameTitle => 'Como vamos chamar essa viagem?';

  @override
  String get routeCreationDatesTitle => 'Quando você quer viajar?';

  @override
  String get routeCreationDatesSubtitle => 'Datas podem mudar depois.';

  @override
  String get routeCreationStartDateLabel => 'Ida';

  @override
  String get routeCreationEndDateLabel => 'Volta';

  @override
  String routeCreationNightsCount(int nights) {
    return '$nights noites';
  }

  @override
  String get routeCreationDatesCoherent => 'datas coerentes';

  @override
  String get routeCreationDatesIncoherent =>
      'A volta precisa ser depois da ida.';

  @override
  String get routeCreationWeekendShortcut => 'fim de semana';

  @override
  String get routeCreationWeekShortcut => '1 semana';

  @override
  String get routeCreationFlexibleShortcut => 'ainda flexível';

  @override
  String get routeCreationLocationsTitle => 'Para onde você vai?';

  @override
  String get routeCreationInterestsTitle => 'O que você quer viver por lá?';

  @override
  String get routeCreationInterestNameLabel => 'Interesse';

  @override
  String get routeCreationInterestDescriptionLabel => 'Descrição (opcional)';

  @override
  String get routeCreationAddInterestButton => 'Adicionar';

  @override
  String get routeCreationReviewHeader => 'REVISÃO';

  @override
  String get routeCreationReviewTitle => 'Confirme sua rota';

  @override
  String get routeCreationNameBlockLabel => 'NOME';

  @override
  String routeCreationInterestsBlockLabel(int count) {
    return '$count INTERESSES';
  }

  @override
  String get routeCreationSubmitCta => 'Enviar para meu agente';

  @override
  String get visualizationTitle => 'Minhas Viagens';

  @override
  String get noTravelsYet => 'Nenhuma viagem ainda.';

  @override
  String get itineraryLabel => 'Roteiro';

  @override
  String stepsCount(int count) {
    return '$count etapas';
  }

  @override
  String get noItinerary => 'Sem roteiro';

  @override
  String get routeLabel => 'Rota';

  @override
  String get hubTitle => 'MINHA VIAGEM';

  @override
  String get hubAwaitingAgentTitle => 'Seu agente está montando seu roteiro';

  @override
  String get hubWhatYouAskedLabel => 'O QUE VOCÊ PEDIU';

  @override
  String get hubEditRouteLink => 'editar rota';

  @override
  String hubInterestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interesses',
      one: '1 interesse',
    );
    return '$_temp0';
  }

  @override
  String get hubNextStepLabel => 'PRÓXIMA ETAPA';

  @override
  String hubInDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'em $days dias',
      one: 'em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get hubToday => 'hoje';

  @override
  String get hubViewDetailsLink => 'Ver detalhes';

  @override
  String get hubStepsLabel => 'ETAPAS';

  @override
  String get hubNightsLabel => 'NOITES';

  @override
  String get hubRouteSummaryLabel => 'RESUMO DA ROTA';

  @override
  String get hubOpenFullItineraryButton => 'Abrir roteiro completo';

  @override
  String get hubComingSoon => 'Em breve.';

  @override
  String get hubEmptyTitle => 'Nenhuma viagem selecionada';

  @override
  String get hubEmptyMessage =>
      'Selecione uma viagem em Início para ver o roteiro.';

  @override
  String get hubGoToHomeCta => 'Ir para o Início';

  @override
  String timelineDayLabel(int dayNumber) {
    return 'Dia $dayNumber';
  }

  @override
  String get timelineNoStepsForDay => 'Nenhuma etapa neste dia';

  @override
  String timelineFreeTimeUntil(String until) {
    return 'Tempo livre · sem etapa até $until';
  }

  @override
  String get timelineTomorrow => 'amanhã';

  @override
  String get timelinePreviousDay => 'Dia anterior';

  @override
  String get timelineNextDay => 'Dia seguinte';

  @override
  String get timelineRentalCarLabel => 'Carro alugado';

  @override
  String get accountTitle => 'Minha Conta';

  @override
  String get logoutButton => 'SAIR';

  @override
  String get notAuthenticated => 'Não autenticado.';

  @override
  String get accountAgentBlockLabel => 'MEU AGENTE';

  @override
  String get accountPersonalDataMenu => 'Dados pessoais';

  @override
  String get accountNotificationsMenu => 'Notificações';

  @override
  String get accountHelpMenu => 'Ajuda';

  @override
  String get accountDarkModeLabel => 'Modo escuro';

  @override
  String accountLanguageLabel(String code) {
    return 'Idioma ($code)';
  }

  @override
  String get comingSoonMessage => 'Em breve.';

  @override
  String get travelStatusRouteCreated => 'Aguardando agente';

  @override
  String get travelStatusItineraryCreated => 'Itinerário publicado';

  @override
  String get travelStatusTravelStarted => 'Em andamento';

  @override
  String get travelStatusTravelFinished => 'Concluída';
}
