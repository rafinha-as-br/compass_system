import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/register_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<RegisterController>();
    final success = await controller.register(
      ClientRegistration(
        name: _nameController.text.trim(),
        cpf: _cpfController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _genderController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado! Faça login para continuar.')),
      );
      Navigator.pop(context);
    }
  }

  String? _requiredValidator(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Campo obrigatório' : null;
  }

  String? _ageValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    return int.tryParse(value.trim()) == null ? 'Idade inválida' : null;
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        centerTitle: true,
      ),
      body: Consumer<RegisterController>(
        builder: (context, controller, child) {
          final state = controller.state;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildField(
                    controller: _nameController,
                    label: 'Nome',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _cpfController,
                    label: 'CPF',
                    keyboardType: TextInputType.number,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _ageController,
                    label: 'Idade',
                    keyboardType: TextInputType.number,
                    validator: _ageValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _genderController,
                    label: 'Gênero',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _phoneController,
                    label: 'Telefone',
                    keyboardType: TextInputType.phone,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _emailController,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'CADASTRAR',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
