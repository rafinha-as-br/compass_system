import 'package:flutter/material.dart';
import 'package:travel_matrix/features/account/data/account_data_source.dart';
import 'package:travel_matrix/features/account/data/account_repository_impl.dart';
import 'package:travel_matrix/features/account/domain/get_agent_profile.dart';
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
  late final GetAgentProfile _getAgentProfile;

  AccountState _state = const AccountState();
  AccountState get state => _state;

  AccountController() {
    _getAgentProfile = GetAgentProfile(
      AccountRepositoryImpl(AccountDataSource()),
    );
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
}
