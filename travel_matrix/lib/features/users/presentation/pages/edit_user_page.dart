import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';

/// Edit User page — same structure as Create User but pre-filled.
class EditUserPage extends StatefulWidget {
  final Client user;

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
  late DateTime _birthDate;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _cpfCtrl = TextEditingController(text: widget.user.cpf);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phoneNumber);
    _sex = widget.user.sex;
    _birthDate = widget.user.birthDate;
    _isActive = widget.user.isActive;
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
      'id': widget.user.id,
      'name': _nameCtrl.text,
      'cpf': _cpfCtrl.text,
      'email': _emailCtrl.text,
      'phoneNumber': _phoneCtrl.text,
      'sex': _sex,
      'birthDate': _birthDate.toIso8601String(),
      'isActive': _isActive,
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        // Pop back to the dashboard (past the view page too)
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                    'Edit: ${widget.user.name}',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cpfCtrl,
                    decoration: const InputDecoration(
                        labelText: 'CPF',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.isEmpty ? 'CPF is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.isEmpty ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.isEmpty ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _sex,
                    decoration: const InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder()),
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
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active Status'),
                    value: _isActive,
                    onChanged: (v) =>
                        setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting ? null : _submit,
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
                              child:
                                  CircularProgressIndicator(
                                      strokeWidth: 2),
                            )
                          : const Text('SAVE CHANGES'),
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
