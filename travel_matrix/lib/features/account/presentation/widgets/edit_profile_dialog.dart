import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/core/validators/cpf_cnpj_validator.dart';
import 'package:travel_matrix/core/validators/email_validator.dart';
import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';
import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/text_fields.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key, required this.profile});

  final AgentProfileViewModel profile;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _emailController = TextEditingController(text: widget.profile.email);
  late final _phoneController = TextEditingController(text: widget.profile.phoneNumber);
  late final _cpfController = TextEditingController(text: widget.profile.cpf);
  late final _cnpjController = TextEditingController(text: widget.profile.cnpj);
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _cpfError;
  String? _cnpjError;
  String? _passwordError;

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

  bool _validate(AppLocalizations l10n) {
    final cpf = _cpfController.text;
    final cnpj = _cnpjController.text;

    setState(() {
      _nameError = _nameController.text.isEmpty ? l10n.requiredField : null;
      _emailError = _emailController.text.isEmpty
          ? l10n.requiredField
          : (!EmailValidator.isValid(_emailController.text) ? l10n.invalidEmail : null);
      _cpfError = (cpf.isNotEmpty && !CpfCnpjValidator.isValidCpf(cpf)) ? l10n.invalidCpf : null;
      _cnpjError = (cnpj.isNotEmpty && !CpfCnpjValidator.isValidCnpj(cnpj)) ? l10n.invalidCnpj : null;
      _passwordError = (_documentsChanged && _passwordController.text.isEmpty)
          ? l10n.confirmPasswordRequired
          : null;
    });

    return _nameError == null &&
        _emailError == null &&
        _cpfError == null &&
        _cnpjError == null &&
        _passwordError == null;
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;

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
            CustomFormField.text(
              label: l10n.clientNameColumn,
              enabled: !_isSaving,
              controller: _nameController,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 12),
            CustomFormField.email(
              label: l10n.loginEmailLabel,
              enabled: !_isSaving,
              controller: _emailController,
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
            ),
            const SizedBox(height: 12),
            CustomFormField.text(
              label: l10n.phoneLabel,
              enabled: !_isSaving,
              controller: _phoneController,
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            CustomFormField.document(
              label: l10n.cpfLabel,
              enabled: !_isSaving,
              controller: _cpfController,
              errorText: _cpfError,
              onChanged: (_) {
                if (_cpfError != null) setState(() => _cpfError = null);
              },
            ),
            const SizedBox(height: 12),
            CustomFormField.document(
              label: l10n.cnpjLabel,
              enabled: !_isSaving,
              controller: _cnpjController,
              errorText: _cnpjError,
              onChanged: (_) {
                if (_cnpjError != null) setState(() => _cnpjError = null);
              },
            ),
            if (_documentsChanged) ...[
              const SizedBox(height: 12),
              CustomFormField.password(
                label: l10n.currentPassword,
                enabled: !_isSaving,
                controller: _passwordController,
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
              ),
            ],
          ],
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
