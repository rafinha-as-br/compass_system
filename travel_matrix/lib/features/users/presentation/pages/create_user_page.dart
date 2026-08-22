import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// User creation form page.
class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _sex = 'M';
  DateTime _birthDate = DateTime(2000, 1, 1);
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<UsersController>();
    final success = await controller.createUser({
      'name': _nameCtrl.text,
      'cpf': _cpfCtrl.text,
      'email': _emailCtrl.text,
      'phoneNumber': _phoneCtrl.text,
      'password': _passwordCtrl.text,
      'sex': _sex,
      'birthDate': _birthDate.toIso8601String(),
      'isActive': true,
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.go(AppRoutes.users);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createUser),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.users);
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
                    l10n.newClientUserFormTitle,
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
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.initialPasswordFieldLabel,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v!.isEmpty ? l10n.passwordRequiredValidation : null,
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
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.birthDateFieldLabel),
                    subtitle: Text(
                      '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _birthDate,
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _birthDate = picked);
                        }
                      },
                    ),
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
                          : Text(l10n.createUserSubmitButton),
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
