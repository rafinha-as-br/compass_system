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
  String get loginTitle => 'Login RouteCraft';

  @override
  String get loginEmailLabel => 'E-mail';

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
  String get accountTitle => 'Minha Conta';

  @override
  String get nameLabel => 'Nome';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get saveChanges => 'SALVAR ALTERAÇÕES';

  @override
  String get logoutButton => 'SAIR';

  @override
  String get notAuthenticated => 'Não autenticado.';
}
