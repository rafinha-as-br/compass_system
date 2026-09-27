import 'package:flutter/foundation.dart';
import 'package:travel_matrix/features/company/data/company_data_source.dart';
import 'package:travel_matrix/features/company/data/company_repository_impl.dart';
import 'package:travel_matrix/features/company/domain/company_use_cases.dart';
import 'package:travel_matrix/features/company/domain/login_preview.dart';
import 'package:travel_matrix/features/company/presentation/view_models/invited_credentials_view_model.dart';

/// Estado do formulário de convite. [createdCredentials] não-nulo comuta a
/// rota para a confirmação pós-criação (a senha só aparece essa vez).
class InviteAgentState {
  final String name;
  final String loginPreview;
  final bool isSubmitting;
  final String? errorMessage;
  final InvitedCredentialsViewModel? createdCredentials;

  const InviteAgentState({
    this.name = '',
    this.loginPreview = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.createdCredentials,
  });

  bool get canSubmit => name.trim().isNotEmpty && !isSubmitting;

  InviteAgentState copyWith({
    String? name,
    String? loginPreview,
    bool? isSubmitting,
    String? errorMessage,
    InvitedCredentialsViewModel? createdCredentials,
  }) {
    return InviteAgentState(
      name: name ?? this.name,
      loginPreview: loginPreview ?? this.loginPreview,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      createdCredentials: createdCredentials ?? this.createdCredentials,
    );
  }
}

class InviteAgentController extends ChangeNotifier {
  final CompanyUseCases _useCases;

  /// Domínio da empresa, usado só para o preview `localPart@domain`.
  final String domain;

  InviteAgentState _state = const InviteAgentState();
  InviteAgentState get state => _state;

  InviteAgentController({required this.domain, CompanyUseCases? useCases})
      : _useCases = useCases ??
            CompanyUseCases(CompanyRepositoryImpl(CompanyDataSource()));

  /// Atualiza nome e preview a cada tecla. O preview é estimativa — a
  /// desambiguação de colisão é do backend.
  void setName(String value) {
    _state = _state.copyWith(
      name: value,
      loginPreview: LoginPreview.login(value, domain),
      errorMessage: _state.errorMessage,
    );
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!_state.canSubmit) return false;
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    final result = await _useCases.inviteAgent(_state.name.trim());
    final invited = result.data;

    if (!result.isSuccess || invited == null) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: result.error ?? 'Failed to invite agent.',
      );
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(
      isSubmitting: false,
      createdCredentials: InvitedCredentialsViewModel.fromDomain(invited),
    );
    notifyListeners();
    return true;
  }
}
