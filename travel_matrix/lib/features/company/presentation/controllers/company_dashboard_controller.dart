import 'package:flutter/foundation.dart';
import 'package:travel_matrix/features/company/data/company_data_source.dart';
import 'package:travel_matrix/features/company/data/company_repository_impl.dart';
import 'package:travel_matrix/features/company/domain/company_use_cases.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/presentation/view_models/agent_row_view_model.dart';
import 'package:travel_matrix/features/company/presentation/view_models/company_header_view_model.dart';

/// Estado do Painel da Empresa. [errorMessage] carrega a mensagem de negócio
/// do backend de uma ação (remover/alterar papel) que falhou; [hasLoadError]
/// é a falha de carga da tela, que mostra texto genérico localizado.
class CompanyDashboardState {
  final bool isLoading;
  final bool hasLoadError;
  final CompanyHeaderViewModel? company;
  final List<AgentRowViewModel> agents;
  final bool isMutating;
  final String? errorMessage;

  const CompanyDashboardState({
    this.isLoading = true,
    this.hasLoadError = false,
    this.company,
    this.agents = const [],
    this.isMutating = false,
    this.errorMessage,
  });

  bool get isOwner => company?.isOwner ?? false;

  int get ownerCount => agents.where((a) => a.isOwner).length;

  /// Regra do único OWNER: quem é o último OWNER não pode ser removido nem
  /// rebaixado — os botões ficam desabilitados e o diálogo mostra o aviso.
  bool isSoleOwner(AgentRowViewModel agent) => agent.isOwner && ownerCount == 1;

  CompanyDashboardState copyWith({
    bool? isLoading,
    bool? hasLoadError,
    CompanyHeaderViewModel? company,
    List<AgentRowViewModel>? agents,
    bool? isMutating,
    String? errorMessage,
  }) {
    return CompanyDashboardState(
      isLoading: isLoading ?? this.isLoading,
      hasLoadError: hasLoadError ?? this.hasLoadError,
      company: company ?? this.company,
      agents: agents ?? this.agents,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage,
    );
  }
}

class CompanyDashboardController extends ChangeNotifier {
  final CompanyUseCases _useCases;

  CompanyDashboardState _state = const CompanyDashboardState();
  CompanyDashboardState get state => _state;

  CompanyDashboardController({CompanyUseCases? useCases})
      : _useCases = useCases ??
            CompanyUseCases(CompanyRepositoryImpl(CompanyDataSource())) {
    load();
  }

  /// Carrega empresa e agentes. Qualquer uma das duas falhando é falha de
  /// carga da tela inteira (a lista não faz sentido sem o papel do agente).
  Future<void> load() async {
    _state = const CompanyDashboardState(isLoading: true);
    notifyListeners();

    final companyResult = await _useCases.getMyCompany();
    final company = companyResult.data;
    if (!companyResult.isSuccess || company == null) {
      _state = const CompanyDashboardState(isLoading: false, hasLoadError: true);
      notifyListeners();
      return;
    }

    final agentsResult = await _useCases.getAgents();
    final agents = agentsResult.data;
    if (!agentsResult.isSuccess || agents == null) {
      _state = const CompanyDashboardState(isLoading: false, hasLoadError: true);
      notifyListeners();
      return;
    }

    _state = CompanyDashboardState(
      isLoading: false,
      company: CompanyHeaderViewModel.fromDomain(company),
      agents: agents
          .map((a) => AgentRowViewModel.fromDomain(
                a,
                currentAgentId: company.currentAgentId,
              ))
          .toList(),
    );
    notifyListeners();
  }

  /// Recarrega só a lista de agentes (após convite, remoção ou troca de
  /// papel), preservando o cabeçalho já carregado.
  Future<void> refreshAgents() async {
    final company = _state.company;
    if (company == null) return load();

    final result = await _useCases.getAgents();
    final agents = result.data;
    if (!result.isSuccess || agents == null) {
      // A mutação que motivou o refresh já deu certo: manter a lista anterior
      // (possivelmente defasada) em vez de derrubar o painel inteiro.
      _state = _state.copyWith(errorMessage: result.error ?? _state.errorMessage);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      agents: agents
          .map((a) => AgentRowViewModel.fromDomain(
                a,
                currentAgentId: company.currentAgentId,
              ))
          .toList(),
      errorMessage: _state.errorMessage,
    );
    notifyListeners();
  }

  Future<bool> removeAgent(String agentId) {
    return _mutate(() => _useCases.removeAgent(agentId));
  }

  Future<bool> changeRole(String agentId, AgentRole role) {
    return _mutate(() => _useCases.changeRole(agentId, role));
  }

  /// Mensagem de erro da última ação, consumida pela tela (ex.: SnackBar ou
  /// diálogo "Ação bloqueada"). Limpa ao ser lida.
  String? takeErrorMessage() {
    final message = _state.errorMessage;
    if (message != null) {
      _state = _state.copyWith(errorMessage: null);
    }
    return message;
  }

  Future<bool> _mutate(Future<dynamic> Function() action) async {
    if (_state.isMutating) return false;
    _state = _state.copyWith(isMutating: true, errorMessage: null);
    notifyListeners();

    final result = await action();
    final success = result.isSuccess == true;

    if (success) {
      _state = _state.copyWith(isMutating: false);
      await refreshAgents();
      return true;
    }

    _state = _state.copyWith(
      isMutating: false,
      errorMessage: (result.error as String?) ?? 'Operation failed.',
    );
    notifyListeners();
    return false;
  }
}
