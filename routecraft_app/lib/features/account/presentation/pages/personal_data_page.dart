import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';
import 'package:routecraft_app/features/account/presentation/controllers/personal_data_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/app_text_field.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`PersonalDataPage()`) is unaffected — the default wiring is used.
  final PersonalDataController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? PersonalDataController(),
      child: const _PersonalDataView(),
    );
  }
}

class _PersonalDataView extends StatefulWidget {
  const _PersonalDataView();

  @override
  State<_PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<_PersonalDataView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  String _sex = 'M';

  /// The form is populated once, the first time the profile arrives — after
  /// that the client is editing local state, so a later rebuild (e.g. right
  /// after a successful save replaces the controller's profile) must never
  /// overwrite what's on screen.
  bool _formPopulated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  static const _genderOptions = ['M', 'F', 'O'];

  void _populateForm(ClientProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phoneNumber;
    _ageController.text = profile.age?.toString() ?? '';
    // The agent-side app also allows 'O' (other) and the backend never
    // validates this string — an unrecognized value must never be handed to
    // DropdownButtonFormField as initialValue, or it asserts.
    _sex = _genderOptions.contains(profile.sex) ? profile.sex : 'M';
    _formPopulated = true;
  }

  Future<void> _onSave(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<PersonalDataController>();
    // A blank/invalid age must never silently wipe out the previously saved
    // value — fall back to it instead of sending null.
    final age = int.tryParse(_ageController.text.trim()) ?? controller.state.profile?.age;

    final success = await controller.save(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      age: age,
      sex: _sex,
    );

    if (!context.mounted) return;
    final state = controller.state;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? l10n.personalDataSaveSuccessMessage : _errorMessage(l10n, state)),
    ));
  }

  Future<void> _onResetPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.personalDataResetPasswordConfirmTitle),
        content: Text(l10n.personalDataResetPasswordConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.personalDataResetPasswordButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final controller = context.read<PersonalDataController>();
    final success = await controller.resetPassword();

    if (!context.mounted) return;
    final state = controller.state;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? l10n.personalDataResetPasswordSuccessMessage : _errorMessage(l10n, state)),
    ));
  }

  String _errorMessage(AppLocalizations l10n, PersonalDataState state) {
    if (state.isConnectivityError) return l10n.personalDataGenericErrorMessage;
    return state.errorMessage ?? l10n.personalDataGenericErrorMessage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PersonalDataController>().state;

    if (state.profile != null && !_formPopulated) {
      _populateForm(state.profile!);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.personalDataTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.profile == null
              ? Center(child: Text(_errorMessage(l10n, state)))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    AppTextField(
                      key: const Key('personalDataNameField'),
                      controller: _nameController,
                      labelText: l10n.personalDataNameLabel,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('personalDataPhoneField'),
                      controller: _phoneController,
                      labelText: l10n.personalDataPhoneLabel,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('personalDataAgeField'),
                      controller: _ageController,
                      labelText: l10n.personalDataAgeLabel,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: const Key('personalDataGenderField'),
                      initialValue: _sex,
                      decoration: InputDecoration(labelText: l10n.personalDataGenderLabel),
                      items: [
                        DropdownMenuItem(value: 'M', child: Text(l10n.maleGenderLabel)),
                        DropdownMenuItem(value: 'F', child: Text(l10n.femaleGenderLabel)),
                        DropdownMenuItem(value: 'O', child: Text(l10n.otherGenderLabel)),
                      ],
                      onChanged: (value) => setState(() => _sex = value ?? _sex),
                    ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(label: l10n.personalDataCpfLabel, value: state.profile!.cpf),
                    const SizedBox(height: 16),
                    _ReadOnlyField(label: l10n.personalDataEmailLabel, value: state.profile!.email),
                    const SizedBox(height: 32),
                    AppButton(
                      key: const Key('personalDataSaveButton'),
                      isLoading: state.isSaving,
                      onPressed: () => _onSave(context),
                      child: Text(l10n.personalDataSaveButton),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      key: const Key('personalDataResetPasswordButton'),
                      variant: AppButtonVariant.secondary,
                      isLoading: state.isResettingPassword,
                      onPressed: () => _onResetPassword(context),
                      child: Text(l10n.personalDataResetPasswordButton),
                    ),
                  ],
                ),
    );
  }
}

/// Read-only display for CPF/e-mail — deliberately not a disabled
/// [AppTextField]: those need a live [TextEditingController], which would
/// have to be recreated (and leaked) on every rebuild just to show a value
/// that never changes.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: TravelAppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: TravelAppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
