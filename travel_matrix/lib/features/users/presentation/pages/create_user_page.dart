import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/shared/widgets/breadcrumb_bar.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';

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
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const BreadcrumbBar(
              items: ['Users Dashboard', 'Create User']),
          Expanded(
            child: SingleChildScrollView(
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
                          'New Client User',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                          validator: (v) =>
                              v!.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cpfCtrl,
                          decoration:
                              const InputDecoration(labelText: 'CPF', border: OutlineInputBorder()),
                          validator: (v) =>
                              v!.isEmpty ? 'CPF is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                          validator: (v) =>
                              v!.isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                          validator: (v) =>
                              v!.isEmpty ? 'Phone is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Initial Password', border: OutlineInputBorder()),
                          obscureText: true,
                          validator: (v) =>
                              v!.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _sex,
                          decoration:
                              const InputDecoration(labelText: 'Sex', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                                value: 'M', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'F', child: Text('Female')),
                            DropdownMenuItem(
                                value: 'O', child: Text('Other')),
                          ],
                          onChanged: (v) =>
                              setState(() => _sex = v ?? 'M'),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Birth Date'),
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
                              backgroundColor:
                                  theme.colorScheme.secondary,
                              foregroundColor:
                                  theme.colorScheme.onSecondary,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('CREATE USER'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
