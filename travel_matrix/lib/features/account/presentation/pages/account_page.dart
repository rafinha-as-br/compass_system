import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/core/validators/cpf_cnpj_validator.dart';
import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';
import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
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
          : state.errorMessage != null
              ? Center(
                  child: Text(
                    state.errorMessage!,
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
    final theme = Theme.of(context);
    final settingsController = context.watch<SettingsController>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          child: Text(
                            profile.initials,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(profile.email),
                              const SizedBox(height: 4),
                              Text(
                                profile.cnpj,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.62),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileSection,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileField(label: l10n.loginEmailLabel, value: profile.email),
                        _ProfileField(label: l10n.cpfLabel, value: profile.cpf),
                        _ProfileField(label: l10n.cnpjLabel, value: profile.cnpj),
                        _ProfileField(label: l10n.phoneLabel, value: profile.phoneNumber),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showEditProfileDialog(context, profile),
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(l10n.editAgentData),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showChangePasswordDialog(context),
                              icon: const Icon(Icons.lock_reset),
                              label: Text(l10n.changePassword),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logOutOfMatrix),
                  onPressed: () => context.read<AuthController>().logout(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    AgentProfileViewModel profile,
  ) {
    final controller = context.read<AccountController>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: controller,
        child: _EditProfileDialog(profile: profile),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.changePassword),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.currentPassword),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPassword),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.updateButton),
            ),
          ],
        );
      },
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.profile});

  final AgentProfileViewModel profile;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _emailController = TextEditingController(text: widget.profile.email);
  late final _phoneController = TextEditingController(text: widget.profile.phoneNumber);
  late final _cpfController = TextEditingController(text: widget.profile.cpf);
  late final _cnpjController = TextEditingController(text: widget.profile.cnpj);
  final _passwordController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  bool get _documentsChanged =>
      _cpfController.text != widget.profile.cpf ||
      _cnpjController.text != widget.profile.cnpj;

  @override
  void initState() {
    super.initState();
    _cpfController.addListener(_onDocumentsFieldChanged);
    _cnpjController.addListener(_onDocumentsFieldChanged);
  }

  void _onDocumentsFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final controller = context.read<AccountController>();
    final result = await controller.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      cpf: _cpfController.text,
      cnpj: _cnpjController.text,
      currentPassword: _passwordController.text.isEmpty ? null : _passwordController.text,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdatedSuccess)),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSaving = false;
        _errorMessage = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editAgentData),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nameController,
                enabled: !_isSaving,
                decoration: InputDecoration(labelText: l10n.clientNameColumn),
                validator: (value) =>
                    (value == null || value.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                enabled: !_isSaving,
                decoration: InputDecoration(labelText: l10n.loginEmailLabel),
                validator: (value) =>
                    (value == null || value.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                enabled: !_isSaving,
                decoration: InputDecoration(labelText: l10n.phoneLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfController,
                enabled: !_isSaving,
                decoration: InputDecoration(labelText: l10n.cpfLabel),
                validator: (value) =>
                    (value != null && value.isNotEmpty && !CpfCnpjValidator.isValidCpf(value))
                        ? l10n.invalidCpf
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpjController,
                enabled: !_isSaving,
                decoration: InputDecoration(labelText: l10n.cnpjLabel),
                validator: (value) =>
                    (value != null && value.isNotEmpty && !CpfCnpjValidator.isValidCnpj(value))
                        ? l10n.invalidCnpj
                        : null,
              ),
              if (_documentsChanged) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isSaving,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.currentPassword),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.confirmPasswordRequired
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.saveButton),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
