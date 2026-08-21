import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Edit User page — same structure as Create User but pre-filled.
class EditUserPage extends StatefulWidget {
  final UserClientViewModel user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cpfCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late String _sex;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _cpfCtrl = TextEditingController(text: widget.user.cpf);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phoneNumber);
    _sex = widget.user.sex;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<UsersController>();
    final success = await controller.updateUser({
      'id': widget.user.backEndId,
      'name': _nameCtrl.text,
      'cpf': _cpfCtrl.text,
      'email': _emailCtrl.text,
      'phoneNumber': _phoneCtrl.text,
      'sex': _sex,
    });

    if (mounted) {
      if (success) {
        context.go('${AppRoutes.users}/${widget.user.localId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editUser),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('${AppRoutes.users}/${widget.user.localId}');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.editUserPageSubtitle(widget.user.name),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.fullNameFieldLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? l10n.nameRequiredValidation : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cpfCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.cpfLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? l10n.cpfRequiredValidation : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.loginEmailLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? l10n.emailRequiredValidation : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumberFieldLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? l10n.phoneRequiredValidation : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _sex,
                    decoration: InputDecoration(
                      labelText: l10n.sexFieldLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'M', child: Text(l10n.maleGenderLabel)),
                      DropdownMenuItem(value: 'F', child: Text(l10n.femaleGenderLabel)),
                      DropdownMenuItem(value: 'O', child: Text(l10n.otherOptionLabel)),
                    ],
                    onChanged: (v) => setState(() => _sex = v ?? 'M'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.saveChangesButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
