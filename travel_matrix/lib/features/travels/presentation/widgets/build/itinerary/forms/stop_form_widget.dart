import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/shared/widgets/text_fields.dart';
import 'field_state.dart';

class StopFormWidget extends StatefulWidget {
  const StopFormWidget({
    super.key,
    required this.stop,
    required this.onChanged,
    required this.onDelete,
  });

  final StopStepViewModel stop;
  final ValueChanged<StopStepViewModel> onChanged;
  final VoidCallback onDelete;

  @override
  State<StopFormWidget> createState() => _StopFormWidgetState();
}

class _StopFormWidgetState extends State<StopFormWidget> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _experienceCtrl;

  late StopFormState _formState;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.stop.name);
    _descCtrl = TextEditingController(text: widget.stop.description);
    _experienceCtrl = TextEditingController();

    _formState = StopFormState(
      name: FieldState(value: widget.stop.name),
      description: FieldState(value: widget.stop.description),
      experiences: List.from(widget.stop.experiences),
    );
  }

  @override
  void didUpdateWidget(covariant StopFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stop.localId != widget.stop.localId) {
      _nameCtrl.text = widget.stop.name;
      _descCtrl.text = widget.stop.description;

      _formState = StopFormState(
        name: FieldState(value: widget.stop.name),
        description: FieldState(value: widget.stop.description),
        experiences: List.from(widget.stop.experiences),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  FieldState<String> _validateRequiredField(String value) {
    if (value.trim().isEmpty) {
      return FieldState(
        value: value,
        error: 'Field cannot be empty',
        isTouched: true,
      );
    }
    return FieldState(value: value, isTouched: true);
  }

  void _onNameChanged(String value) {
    final validatedField = _validateRequiredField(value);
    setState(() {
      _formState = _formState.copyWith(name: validatedField);
    });
    _emitIfValid();
  }

  void _onDescChanged(String value) {
    setState(() {
      _formState = _formState.copyWith(
        description: FieldState(value: value, isTouched: true),
      );
    });
    _emitIfValid();
  }

  void _addExperience() {
    if (_experienceCtrl.text.isNotEmpty) {
      setState(() {
        final newExperiences = List<String>.from(_formState.experiences)
          ..add(_experienceCtrl.text);
        _formState = _formState.copyWith(experiences: newExperiences);
        _experienceCtrl.clear();
      });
      _emitIfValid();
    }
  }

  void _removeExperience(String exp) {
    setState(() {
      final newExperiences = List<String>.from(_formState.experiences)
        ..remove(exp);
      _formState = _formState.copyWith(experiences: newExperiences);
    });
    _emitIfValid();
  }

  void _emitIfValid() {
    if (!_formState.isValid) {
      return;
    }

    widget.onChanged(
      widget.stop.copyWith(
        name: _formState.name.value,
        description: _formState.description.value,
        experiences: _formState.experiences,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFormField.text(
            label: 'Stop Name',
            enabled: true,
            controller: _nameCtrl,
            errorText: _formState.name.isTouched ? _formState.name.error : null,
            onChanged: _onNameChanged,
          ),
          const SizedBox(height: 12),
          CustomFormField.text(
            label: 'Description',
            enabled: true,
            controller: _descCtrl,
            errorText: _formState.description.isTouched
                ? _formState.description.error
                : null,
            onChanged: _onDescChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomFormField.text(
                  label: 'Add Experience',
                  enabled: true,
                  controller: _experienceCtrl,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addExperience,
                icon: const Icon(Icons.add_circle),
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _formState.experiences
                .map(
                  (e) => Chip(
                    label: Text(e, style: const TextStyle(fontSize: 12)),
                    onDeleted: () => _removeExperience(e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Delete Step'),
          ),
        ],
      ),
    );
  }
}

class StopFormState {
  final FieldState<String> name;
  final FieldState<String> description;
  final List<String> experiences;

  bool get isValid => name.isValid;

  const StopFormState({
    required this.name,
    required this.description,
    required this.experiences,
  });

  StopFormState copyWith({
    FieldState<String>? name,
    FieldState<String>? description,
    List<String>? experiences,
  }) {
    return StopFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      experiences: experiences ?? this.experiences,
    );
  }
}
