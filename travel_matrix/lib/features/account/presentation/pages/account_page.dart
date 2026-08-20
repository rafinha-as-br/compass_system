import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';
import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';
import 'package:travel_matrix/features/account/presentation/widgets/logout_button.dart';
import 'package:travel_matrix/features/account/presentation/widgets/preferences_card.dart';
import 'package:travel_matrix/features/account/presentation/widgets/profile_details_card.dart';
import 'package:travel_matrix/features/account/presentation/widgets/profile_header_card.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class AccountPage extends StatelessWidget {
  final AccountController? controller;

  const AccountPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final providedController = controller;
    return providedController != null
        ? ChangeNotifierProvider.value(
            value: providedController,
            child: const _AccountView(),
          )
        : ChangeNotifierProvider(
            create: (_) => AccountController(),
            child: const _AccountView(),
          );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountController>().state;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentSettings)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.hasError
              ? Center(
                  child: Text(
                    l10n.failedToLoadProfile,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : _AccountContent(profile: state.profile!, l10n: l10n),
    );
  }
}

class _AccountContent extends StatelessWidget {
  final AgentProfileViewModel profile;
  final AppLocalizations l10n;

  const _AccountContent({
    required this.profile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeaderCard(profile: profile),
                const SizedBox(height: 20),
                ProfileDetailsCard(profile: profile, l10n: l10n),
                const SizedBox(height: 20),
                PreferencesCard(l10n: l10n),
                const SizedBox(height: 24),
                LogoutButton(l10n: l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
