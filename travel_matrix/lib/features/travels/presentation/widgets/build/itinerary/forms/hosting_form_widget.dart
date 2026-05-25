import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/shared/widgets/text_fields.dart';
import 'field_state.dart';

class HostingFormWidget extends StatefulWidget {
  const HostingFormWidget({
    super.key,
    required this.hosting,
    required this.onChanged,
    required this.onDelete,
  });

  final HostingStepViewModel hosting;
  final ValueChanged<HostingStepViewModel> onChanged;
  final VoidCallback onDelete;

  @override
  State<HostingFormWidget> createState() => _HostingFormWidgetState();
}

class _HostingFormWidgetState extends State<HostingFormWidget> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _checkInCtrl;
  late final TextEditingController _checkOutCtrl;

  late HostingFormState _formState;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.hosting.placeName);
    _addressCtrl = TextEditingController(text: widget.hosting.address);
    _checkInCtrl = TextEditingController(text: _formatDate(widget.hosting.checkIn));
    _checkOutCtrl = TextEditingController(text: _formatDate(widget.hosting.checkOut));

    _formState = HostingFormState(
      placeName: FieldState(value: widget.hosting.placeName),
      address: FieldState(value: widget.hosting.address),
      checkIn: widget.hosting.checkIn,
      checkOut: widget.hosting.checkOut,
    );
  }

  @override
  void didUpdateWidget(covariant HostingFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hosting != widget.hosting) {
      _nameCtrl.text = widget.hosting.placeName;
      _addressCtrl.text = widget.hosting.address;
      _checkInCtrl.text = _formatDate(widget.hosting.checkIn);
      _checkOutCtrl.text = _formatDate(widget.hosting.checkOut);

      _formState = HostingFormState(
        placeName: FieldState(value: widget.hosting.placeName),
        address: FieldState(value: widget.hosting.address),
        checkIn: widget.hosting.checkIn,
        checkOut: widget.hosting.checkOut,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  FieldState<String> _validateRequiredField(String value) {
    if (value.trim().isEmpty) {
      return FieldState(
        value: value,
        error: 'Field cannot be empty',
        isTouched: true,
      );
    }
    return FieldState(
      value: value,
      isTouched: true,
    );
  }

  void _onNameChanged(String value) {
    final validatedField = _validateRequiredField(value);
    setState(() {
      _formState = _formState.copyWith(placeName: validatedField);
    });
    _emitIfValid();
  }

  void _onAddressChanged(String value) {
    final validatedField = _validateRequiredField(value);
    setState(() {
      _formState = _formState.copyWith(address: validatedField);
    });
    _emitIfValid();
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? _formState.checkIn : _formState.checkOut;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInCtrl.text = _formatDate(picked);
          _formState = _formState.copyWith(checkIn: picked);
        } else {
          _checkOutCtrl.text = _formatDate(picked);
          _formState = _formState.copyWith(checkOut: picked);
        }
      });
      _emitIfValid();
    }
  }

  void _emitIfValid() {
    if (!_formState.isValid) {
      return;
    }

    widget.onChanged(
      widget.hosting.copyWith(
        placeName: _formState.placeName.value,
        address: _formState.address.value,
        checkIn: _formState.checkIn,
        checkOut: _formState.checkOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.secondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFormField.text(
            label: 'Hosting Name',
            enabled: true,
            controller: _nameCtrl,
            errorText: _formState.placeName.isTouched ? _formState.placeName.error : null,
            onChanged: _onNameChanged,
          ),
          const SizedBox(height: 12),
          CustomFormField.text(
            label: 'Address',
            enabled: true,
            controller: _addressCtrl,
            errorText: _formState.address.isTouched ? _formState.address.error : null,
            onChanged: _onAddressChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomFormField.date(
                  label: 'Check-in',
                  enabled: true,
                  controller: _checkInCtrl,
                  onTap: () => _pickDate(isCheckIn: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomFormField.date(
                  label: 'Check-out',
                  enabled: true,
                  controller: _checkOutCtrl,
                  onTap: () => _pickDate(isCheckIn: false),
                ),
              ),
            ],
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

class HostingFormState {
  final FieldState<String> placeName;
  final FieldState<String> address;
  final DateTime checkIn;
  final DateTime checkOut;

  bool get isValid => placeName.isValid && address.isValid;

  const HostingFormState({
    required this.placeName,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  });

  HostingFormState copyWith({
    FieldState<String>? placeName,
    FieldState<String>? address,
    DateTime? checkIn,
    DateTime? checkOut,
  }) {
    return HostingFormState(
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
    );
  }
}
