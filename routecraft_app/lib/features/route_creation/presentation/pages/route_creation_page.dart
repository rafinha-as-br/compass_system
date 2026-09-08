import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/app_text_field.dart';
import 'package:routecraft_app/shared/widgets/date_field.dart';

class RouteCreationPage extends StatelessWidget {
  const RouteCreationPage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`RouteCreationPage()`) is unaffected — the default wiring is used.
  final RouteCreationController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? RouteCreationController(),
      child: const _RouteCreationView(),
    );
  }
}

class _RouteCreationView extends StatelessWidget {
  const _RouteCreationView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();
    final state = controller.state;

    if (state.isSuccess) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.successTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: TravelAppColors.success, size: 80),
              const SizedBox(height: 16),
              Text(l10n.routeCreatedSuccess, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 32),
              AppButton(onPressed: () => context.pop(), child: Text(l10n.backToHome)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createRouteTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: state.isReviewStep ? const _ReviewStep() : _StepIndicator(step: state.currentStep + 1),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text(
            l10n.routeCreationStepIndicator(step, routeCreationStepCount),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        switch (step) {
          1 => const _NameStep(),
          2 => const _DatesStep(),
          3 => const _LocationsStep(),
          4 => const _InterestsStep(),
          _ => const _ParticipantsStep(),
        },
      ],
    );
  }
}

/// Shared shell for a wizard step: title, optional subtitle, the step's own
/// fields, and the Continue/Back controls — every step follows this same
/// single-card layout in wireframe 1a.
class _WizardStep extends StatelessWidget {
  const _WizardStep({
    required this.title,
    this.subtitle,
    required this.child,
    required this.onContinue,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
          const SizedBox(height: 24),
          child,
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: AppButton(onPressed: onContinue, child: Text(l10n.nextButton)),
          ),
          if (onBack != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onBack, child: Text(l10n.backButton)),
          ],
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();

    return _WizardStep(
      title: l10n.routeCreationNameTitle,
      onContinue: controller.isNameValid ? controller.nextStep : null,
      child: AppTextField(
        controller: controller.tripNameController,
        labelText: l10n.tripNameLabel,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

class _DatesStep extends StatelessWidget {
  const _DatesStep();

  Future<void> _pickDate(BuildContext context, RouteCreationController controller, {required bool isStart}) async {
    final initial = (isStart ? controller.startDate : controller.endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    if (isStart) {
      controller.setStartDate(picked);
    } else {
      controller.setEndDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();
    final theme = Theme.of(context);
    final nights = controller.nights;

    return _WizardStep(
      title: l10n.routeCreationDatesTitle,
      subtitle: l10n.routeCreationDatesSubtitle,
      onContinue: controller.isDatesValid ? controller.nextStep : null,
      onBack: controller.previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DateField(
            label: l10n.routeCreationStartDateLabel,
            date: controller.startDate,
            onTap: () => _pickDate(context, controller, isStart: true),
          ),
          const SizedBox(height: 16),
          DateField(
            label: l10n.routeCreationEndDateLabel,
            date: controller.endDate,
            onTap: () => _pickDate(context, controller, isStart: false),
          ),
          const SizedBox(height: 12),
          if (controller.startDate != null && controller.endDate != null)
            Text(
              controller.isDatesValid
                  ? '✓ ${l10n.routeCreationNightsCount(nights!)} — ${l10n.routeCreationDatesCoherent}'
                  : l10n.routeCreationDatesIncoherent,
              style: TextStyle(color: controller.isDatesValid ? TravelAppColors.success : theme.colorScheme.error),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(label: Text(l10n.routeCreationWeekendShortcut), onPressed: controller.applyWeekendShortcut),
              ActionChip(label: Text(l10n.routeCreationWeekShortcut), onPressed: controller.applyWeekShortcut),
              ActionChip(label: Text(l10n.routeCreationFlexibleShortcut), onPressed: controller.applyFlexibleShortcut),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationsStep extends StatelessWidget {
  const _LocationsStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();

    return _WizardStep(
      title: l10n.routeCreationLocationsTitle,
      onContinue: controller.isLocationsValid ? controller.nextStep : null,
      onBack: controller.previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(controller: controller.startLocationController, labelText: l10n.startLocationLabel),
          const SizedBox(height: 16),
          AppTextField(controller: controller.destinationController, labelText: l10n.destinationLabel),
        ],
      ),
    );
  }
}

class _InterestsStep extends StatefulWidget {
  const _InterestsStep();

  @override
  State<_InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<_InterestsStep> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addInterest(RouteCreationController controller) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    controller.addInterestPoint(name, _descriptionController.text.trim());
    _nameController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();

    return _WizardStep(
      title: l10n.routeCreationInterestsTitle,
      onContinue: controller.nextStep,
      onBack: controller.previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.interestPoints.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.interestPoints
                  .map((point) => Chip(
                        label: Text(point.name),
                        onDeleted: () => controller.removeInterestPoint(point.domainId),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          AppTextField(controller: _nameController, labelText: l10n.routeCreationInterestNameLabel),
          const SizedBox(height: 16),
          AppTextField(controller: _descriptionController, labelText: l10n.routeCreationInterestDescriptionLabel),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _addInterest(controller),
              icon: const Icon(Icons.add),
              label: Text(l10n.routeCreationAddInterestButton),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.observationsController,
            labelText: l10n.routeCreationObservationsLabel,
            hintText: l10n.routeCreationObservationsHint,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _ParticipantsStep extends StatefulWidget {
  const _ParticipantsStep();

  @override
  State<_ParticipantsStep> createState() => _ParticipantsStepState();
}

class _ParticipantsStepState extends State<_ParticipantsStep> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _sex;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addParticipant(RouteCreationController controller) {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final sex = _sex;
    if (name.isEmpty || age.isEmpty || sex == null) return;
    controller.addParticipant(name: name, age: age, sex: sex);
    _nameController.clear();
    _ageController.clear();
    setState(() => _sex = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();

    return _WizardStep(
      title: l10n.routeCreationParticipantsTitle,
      subtitle: l10n.routeCreationParticipantsSubtitle,
      onContinue: controller.isParticipantsValid ? controller.nextStep : null,
      onBack: controller.previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final person in controller.participants)
            Padding(
              key: ValueKey(person.domainId),
              padding: const EdgeInsets.only(bottom: 12),
              child: _ParticipantCard(
                person: person,
                isClient: controller.isClientParticipant(person),
                onChanged: (name, age, sex) =>
                    controller.updateParticipant(person.domainId, name: name, age: age, sex: sex),
                onRemove: () => controller.removeParticipant(person.domainId),
              ),
            ),
          const Divider(height: 32),
          AppTextField(controller: _nameController, labelText: l10n.routeCreationParticipantNameLabel),
          const SizedBox(height: 16),
          AppTextField(
            controller: _ageController,
            labelText: l10n.routeCreationParticipantAgeLabel,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _sex,
            decoration: InputDecoration(
              labelText: l10n.routeCreationParticipantSexLabel,
              border: const OutlineInputBorder(borderSide: BorderSide(color: TravelAppColors.border)),
            ),
            items: [
              DropdownMenuItem(value: 'M', child: Text(l10n.routeCreationParticipantSexMale)),
              DropdownMenuItem(value: 'F', child: Text(l10n.routeCreationParticipantSexFemale)),
              DropdownMenuItem(value: 'O', child: Text(l10n.routeCreationParticipantSexOther)),
            ],
            onChanged: (value) => setState(() => _sex = value),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _addParticipant(controller),
              icon: const Icon(Icons.add),
              label: Text(l10n.routeCreationAddParticipantButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.person,
    required this.isClient,
    required this.onChanged,
    required this.onRemove,
  });

  final Person person;
  final bool isClient;
  final void Function(String name, String age, String sex) onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${person.domainId}-name'),
                    initialValue: person.name,
                    decoration: InputDecoration(labelText: l10n.routeCreationParticipantNameLabel),
                    onChanged: (value) => onChanged(value, person.age, person.sex),
                  ),
                ),
                if (isClient)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(label: Text(l10n.routeCreationParticipantYouTag)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.editRouteRemoveInterestTooltip,
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${person.domainId}-age'),
                    initialValue: person.age,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.routeCreationParticipantAgeLabel),
                    onChanged: (value) => onChanged(person.name, value, person.sex),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('${person.domainId}-sex'),
                    initialValue: person.sex.isEmpty ? null : person.sex,
                    decoration: InputDecoration(labelText: l10n.routeCreationParticipantSexLabel),
                    items: [
                      DropdownMenuItem(value: 'M', child: Text(l10n.routeCreationParticipantSexMale)),
                      DropdownMenuItem(value: 'F', child: Text(l10n.routeCreationParticipantSexFemale)),
                      DropdownMenuItem(value: 'O', child: Text(l10n.routeCreationParticipantSexOther)),
                    ],
                    onChanged: (value) => onChanged(person.name, person.age, value ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<RouteCreationController>();
    final state = controller.state;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.routeCreationReviewHeader,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(l10n.routeCreationReviewTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _ReviewBlock(
            label: l10n.routeCreationNameBlockLabel,
            value: controller.tripNameController.text,
            onEdit: () => controller.editStep(0),
          ),
          const SizedBox(height: 16),
          _ReviewBlock(
            label: l10n.routeLabel.toUpperCase(),
            value: '${controller.startLocationController.text} → ${controller.destinationController.text}',
            onEdit: () => controller.editStep(2),
          ),
          const SizedBox(height: 16),
          _ReviewBlock(
            label: l10n.routeCreationInterestsBlockLabel(controller.interestPoints.length),
            value: controller.interestPoints.isEmpty
                ? '—'
                : controller.interestPoints.map((p) => p.name).join(' · '),
            onEdit: () => controller.editStep(3),
          ),
          const SizedBox(height: 16),
          _ReviewBlock(
            label: l10n.routeCreationParticipantsBlockLabel(controller.participants.length),
            value: controller.participants.map((p) => p.name).join(' · '),
            onEdit: () => controller.editStep(4),
          ),
          if (controller.observationsController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _ReviewBlock(
              label: l10n.routeCreationObservationsBlockLabel,
              value: controller.observationsController.text.trim(),
              onEdit: () => controller.editStep(3),
            ),
          ],
          if (state.hasNoSession) ...[
            const SizedBox(height: 16),
            Text(l10n.notAuthenticated, style: TextStyle(color: theme.colorScheme.error)),
          ] else if (state.submitErrorMessage != null) ...[
            const SizedBox(height: 16),
            Text(l10n.failedToCreateRoute(state.submitErrorMessage!), style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: AppButton(
              onPressed: state.isSubmitting ? null : controller.submitRoute,
              isLoading: state.isSubmitting,
              child: Text(l10n.routeCreationSubmitCta),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: state.isSubmitting ? null : controller.previousStep,
            child: Text(l10n.backButton),
          ),
        ],
      ),
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  const _ReviewBlock({required this.label, required this.value, required this.onEdit});

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            TextButton(onPressed: onEdit, child: Text(l10n.editButton)),
          ],
        ),
      ),
    );
  }
}
