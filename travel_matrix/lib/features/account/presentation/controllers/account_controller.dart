import 'package:flutter/material.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/account/data/account_data_source.dart';
import 'package:travel_matrix/features/account/data/account_repository_impl.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/domain/get_agent_profile.dart';
import 'package:travel_matrix/features/account/domain/update_agent_profile.dart';
import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';

class AccountState {
  final bool isLoading;
  final AgentProfileViewModel? profile;
  final String? errorMessage;

  const AccountState({
    this.isLoading = true,
    this.profile,
    this.errorMessage,
  });
}

class AccountController extends ChangeNotifier {
  final GetAgentProfile _getAgentProfile;
  final UpdateAgentProfile _updateAgentProfile;

  AccountState _state = const AccountState();
  AccountState get state => _state;

  AccountController({
    GetAgentProfile? getAgentProfile,
    UpdateAgentProfile? updateAgentProfile,
  })  : _getAgentProfile =
            getAgentProfile ?? GetAgentProfile(AccountRepositoryImpl(AccountDataSource())),
        _updateAgentProfile = updateAgentProfile ??
            UpdateAgentProfile(AccountRepositoryImpl(AccountDataSource())) {
    load();
  }

  Future<void> load() async {
    _state = const AccountState(isLoading: true);
    notifyListeners();

    try {
      final profile = await _getAgentProfile();
      _state = AccountState(
        isLoading: false,
        profile: AgentProfileViewModel.fromDomain(profile),
      );
    } catch (e) {
      _state = AccountState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<Result<AgentProfileViewModel>> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String cpf,
    required String cnpj,
    String? currentPassword,
  }) async {
    final current = _state.profile;
    if (current == null) {
      return const Result.failure('Profile not loaded.');
    }

    try {
      final updated = await _updateAgentProfile(
        current: AgentProfile(
          id: current.id,
          name: current.name,
          email: current.email,
          cpf: current.cpf,
          cnpj: current.cnpj,
          phoneNumber: current.phoneNumber,
        ),
        updated: AgentProfile(
          id: current.id,
          name: name,
          email: email,
          cpf: cpf,
          cnpj: cnpj,
          phoneNumber: phoneNumber,
        ),
        currentPassword: currentPassword,
      );

      final viewModel = AgentProfileViewModel.fromDomain(updated);
      _state = AccountState(isLoading: false, profile: viewModel);
      notifyListeners();
      return Result.success(viewModel);
    } catch (e) {
      final message = e is StateError ? e.message : 'Could not update profile.';
      return Result.failure(message);
    }
  }
}
