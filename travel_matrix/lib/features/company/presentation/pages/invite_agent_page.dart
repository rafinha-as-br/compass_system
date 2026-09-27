import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/company/presentation/controllers/company_dashboard_controller.dart';
import 'package:travel_matrix/features/company/presentation/controllers/invite_agent_controller.dart';
import 'package:travel_matrix/features/company/presentation/view_models/invited_credentials_view_model.dart';
import 'package:travel_matrix/features/company/presentation/widgets/invite_success_panel.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/utils/validators.dart';
import 'package:travel_matrix/shared/widgets/form_error_message.dart';
import 'package:travel_matrix/shared/widgets/primary_submit_button.dart';

/// Convidar Agente (`/company/invite`) — rota própria, só OWNER chega aqui
/// (o botão não renderiza para MEMBER). Depois do POST a confirmação
/// substitui o formulário na mesma rota: a senha temporária só aparece uma
/// vez, então não navega para fora sozinho.
class InviteAgentPage extends StatelessWidget {
  /// Controller injetável para testes; em produção nasce do domínio da
  /// empresa já carregada pelo [CompanyDashboardController] do provider.
  final InviteAgentController? controller;

  const InviteAgentPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final providedController = controller;
    if (providedController != null) {
      return ChangeNotifierProvider.value(
        value: providedController,
        child: const _InviteAgentView(),
      );
    }
    final domain = context.read<CompanyDashboardController>().state.company?.domain ?? '';
    return ChangeNotifierProvider(
      create: (_) => InviteAgentController(domain: domain),
      child: const _InviteAgentView(),
    );
  }
}

class _InviteAgentView extends StatelessWidget {
  const _InviteAgentView();

  void _backToPanel(BuildContext context) {
    // A lista do Painel precisa refletir o convite recém-criado.
    context.read<CompanyDashboardController?>()?.refreshAgents();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.company);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<InviteAgentController>().state;
    final l10n = AppLocalizations.of(context)!;
    final credentials = state.createdCredentials;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inviteAgentTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _backToPanel(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: credentials != null
                ? InviteSuccessPanel(
                    credentials: credentials,
                    onCopyCredentials: () => _copyCredentials(context, credentials),
                    onBackToPanel: () => _backToPanel(context),
                  )
                : const _InviteForm(),
          ),
        ),
      ),
    );
  }

  Future<void> _copyCredentials(
    BuildContext context,
    InvitedCredentialsViewModel credentials,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final text = '${l10n.loginLabelCaps}: ${credentials.login}\n'
        '${l10n.temporaryPasswordLabel}: ${credentials.temporaryPassword}';
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(l10n.credentialsCopiedSnack)));
  }
}

class _InviteForm extends StatefulWidget {
  const _InviteForm();

  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<InviteAgentController>().submit();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InviteAgentController>();
    final state = controller.state;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.inviteHelpText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            enabled: !state.isSubmitting,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.agentNameFieldLabel,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onChanged: controller.setName,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) =>
                Validators.required(v?.trim(), l10n.agentNameRequiredValidation),
          ),
          const SizedBox(height: 16),
          _LoginPreviewField(
            loginPreview: state.loginPreview,
            domain: controller.domain,
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.roleFieldLabel,
              helperText: l10n.roleFixedNote,
              border: const OutlineInputBorder(),
              enabled: false,
            ),
            child: const Text('MEMBER'),
          ),
          const SizedBox(height: 24),
          if (state.errorMessage != null) ...[
            FormErrorMessage(message: state.errorMessage!),
            const SizedBox(height: 16),
          ],
          PrimarySubmitButton(
            label: l10n.inviteSubmitButton,
            isLoading: state.isSubmitting,
            onPressed: state.canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}

/// Campo desabilitado com o login estimado: local-part em text primary e
/// `@dominio` em text secondary. Só preview — a desambiguação é do backend.
class _LoginPreviewField extends StatelessWidget {
  final String loginPreview;
  final String domain;

  const _LoginPreviewField({required this.loginPreview, required this.domain});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final at = loginPreview.indexOf('@');
    final localPart = at > 0 ? loginPreview.substring(0, at) : '';

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.loginPreviewLabel,
        helperText: l10n.loginPreviewHelper,
        helperMaxLines: 3,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixText: l10n.readOnlyTag,
        border: const OutlineInputBorder(),
        enabled: false,
      ),
      isEmpty: localPart.isEmpty,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: localPart,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            TextSpan(
              text: localPart.isEmpty ? '' : '@$domain',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
