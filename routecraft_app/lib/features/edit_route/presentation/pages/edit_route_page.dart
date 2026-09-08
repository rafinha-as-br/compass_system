import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/features/edit_route/presentation/controllers/edit_route_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/app_text_field.dart';
import 'package:routecraft_app/shared/widgets/date_field.dart';

/// Lets the client edit the route of an existing trip — wireframe 1i.
/// `PUT /travels/{id}/route` never touches the itinerary, so when one is
/// already published this shows a warning and an explicit diff of pending
/// changes before anything is sent, instead of silently resubmitting.
class EditRoutePage extends StatelessWidget {
  const EditRoutePage({super.key, required this.travel, this.controller});

  final Travel travel;

  /// Injectable for widget tests with fixed use cases, without depending on
  /// the real network/singleton wiring. In production the call site is
  /// unaffected — the default wiring is used.
  final EditRouteController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          controller ??
          EditRouteController(
            travelId: travel.backEndId!,
            original: travel.routePlan,
            showPublishedWarning: travel.hasItinerary,
            clientName: travel.clientName,
            originalParticipants: travel.participantsList,
          ),
      child: const _EditRouteView(),
    );
  }
}

class _EditRouteView extends StatelessWidget {
  const _EditRouteView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<EditRouteController>();
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
              Text(l10n.editRouteUpdateSuccess, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 32),
              AppButton(onPressed: () => context.pop(), child: Text(l10n.backButton)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editRouteTitle),
        actions: [
          TextButton(
            onPressed: controller.hasChanges && !state.isSubmitting ? controller.submit : null,
            child: Text(l10n.editRouteSaveButton),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.showPublishedWarning) ...[
                _PublishedWarningBanner(message: l10n.editRoutePublishedWarning),
                const SizedBox(height: 24),
              ],
              _ChangeMarkedField(
                changed: controller.destinationChanged,
                child: AppTextField(controller: controller.destinationController, labelText: l10n.destinationLabel),
              ),
              const SizedBox(height: 16),
              _ChangeMarkedField(
                changed: controller.startLocationChanged,
                child: AppTextField(controller: controller.startLocationController, labelText: l10n.startLocationLabel),
              ),
              const SizedBox(height: 16),
              _ChangeMarkedField(
                changed: controller.startDateChanged,
                child: DateField(
                  label: l10n.routeCreationStartDateLabel,
                  date: controller.startDate,
                  onTap: () => _pickDate(context, controller, isStart: true),
                ),
              ),
              const SizedBox(height: 16),
              _ChangeMarkedField(
                changed: controller.endDateChanged,
                child: DateField(
                  label: l10n.routeCreationEndDateLabel,
                  date: controller.endDate,
                  onTap: () => _pickDate(context, controller, isStart: false),
                ),
              ),
              const SizedBox(height: 24),
              const _InterestsSection(),
              const SizedBox(height: 24),
              const _ParticipantsSection(),
              if (controller.hasChanges) ...[
                const SizedBox(height: 24),
                _PendingChangesBlock(controller: controller),
              ],
              if (state.submitErrorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.editRouteSubmitError(state.submitErrorMessage!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: AppButton(
                  onPressed: controller.hasChanges && !state.isSubmitting ? controller.submit : null,
                  isLoading: state.isSubmitting,
                  child: Text(l10n.editRouteSubmitCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, EditRouteController controller, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? controller.startDate : controller.endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    if (isStart) {
      controller.setStartDate(picked);
    } else {
      controller.setEndDate(picked);
    }
  }
}

class _PublishedWarningBanner extends StatelessWidget {
  const _PublishedWarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TravelAppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TravelAppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_outlined, color: TravelAppColors.warning),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Wraps a field with a small "changed" caption underneath it when its
/// value differs from the saved route — wireframe 1i marks edited fields
/// visually so the client sees exactly what they're about to send.
class _ChangeMarkedField extends StatelessWidget {
  const _ChangeMarkedField({required this.changed, required this.child});

  final bool changed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!changed) return child;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
          child: Text(
            l10n.editRouteChangedLabel,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _InterestsSection extends StatefulWidget {
  const _InterestsSection();

  @override
  State<_InterestsSection> createState() => _InterestsSectionState();
}

class _InterestsSectionState extends State<_InterestsSection> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addInterest(EditRouteController controller) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    controller.addInterestPoint(name, _descriptionController.text.trim());
    _nameController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<EditRouteController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.interestsStep,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 8),
        for (final point in controller.interestPoints)
          _InterestRow(
            point: point,
            pendingRemoval: controller.isPendingRemoval(point.domainId),
            onRemove: () => controller.markForRemoval(point.domainId),
            onUndo: () => controller.undoRemoval(point.domainId),
          ),
        if (controller.interestPoints.isNotEmpty) const SizedBox(height: 16),
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
      ],
    );
  }
}

class _InterestRow extends StatelessWidget {
  const _InterestRow({required this.point, required this.pendingRemoval, required this.onRemove, required this.onUndo});

  final InterestPoint point;
  final bool pendingRemoval;
  final VoidCallback onRemove;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              point.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: pendingRemoval ? TextDecoration.lineThrough : null,
                color: pendingRemoval ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : null,
              ),
            ),
          ),
          if (pendingRemoval)
            TextButton(onPressed: onUndo, child: Text(l10n.editRouteUndoLink))
          else
            IconButton(onPressed: onRemove, icon: const Icon(Icons.close), tooltip: l10n.editRouteRemoveInterestTooltip),
        ],
      ),
    );
  }
}

class _ParticipantsSection extends StatefulWidget {
  const _ParticipantsSection();

  @override
  State<_ParticipantsSection> createState() => _ParticipantsSectionState();
}

class _ParticipantsSectionState extends State<_ParticipantsSection> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _sex;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addParticipant(EditRouteController controller) {
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
    final controller = context.watch<EditRouteController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.participantsSectionLabel,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 8),
        for (final person in controller.participants)
          Padding(
            key: ValueKey(person.domainId),
            padding: const EdgeInsets.only(bottom: 12),
            child: _ParticipantRow(
              person: person,
              isClient: controller.isClientParticipant(person),
              pendingRemoval: controller.isParticipantPendingRemoval(person.domainId),
              onChanged: (name, age, sex) =>
                  controller.updateParticipant(person.domainId, name: name, age: age, sex: sex),
              onRemove: () => controller.markParticipantForRemoval(person.domainId),
              onUndo: () => controller.undoParticipantRemoval(person.domainId),
            ),
          ),
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
          decoration: InputDecoration(labelText: l10n.routeCreationParticipantSexLabel),
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
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.person,
    required this.isClient,
    required this.pendingRemoval,
    required this.onChanged,
    required this.onRemove,
    required this.onUndo,
  });

  final Person person;
  final bool isClient;
  final bool pendingRemoval;
  final void Function(String name, String age, String sex) onChanged;
  final VoidCallback onRemove;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (pendingRemoval) {
      return Row(
        children: [
          Expanded(
            child: Text(
              person.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          TextButton(onPressed: onUndo, child: Text(l10n.editRouteUndoLink)),
        ],
      );
    }

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

class _PendingChangesBlock extends StatelessWidget {
  const _PendingChangesBlock({required this.controller});

  final EditRouteController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final descriptions = editRouteChangeDescriptions(controller, l10n, languageCode);
    final changeCount = descriptions.length;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.editRoutePendingChangesCount(changeCount),
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(descriptions.join(' · '), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
