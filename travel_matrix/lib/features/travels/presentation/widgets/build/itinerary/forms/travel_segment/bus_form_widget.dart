
import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import '../../../../../../../../shared/widgets/text_fields.dart';
import '../field_state.dart';
import 'package:intl/intl.dart';

/// Bus form widget, receives the [BusViewModel] and a callback to update it
class BusForm extends StatefulWidget {
  const BusForm({
    super.key,
    required this.busViewModel,
    required this.onChanged,
  });

  final BusViewModel busViewModel;

  /// Called ONLY when form is valid
  final ValueChanged<BusViewModel> onChanged;

  @override
  State<BusForm> createState() => _BusFormState();
}

class _BusFormState extends State<BusForm> {

  late final TextEditingController _travelNumberCtrl;
  late final TextEditingController _travelCompanyCtrl;
  late final TextEditingController _departureGateCtrl;
  late final TextEditingController _departureDateTimeCtrl;
  late final TextEditingController _busStationNameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _detailsCtrl;

  late BusFormState _formState;

  @override
  void initState() {
    super.initState();

    _travelNumberCtrl = TextEditingController(
      text: widget.busViewModel.travelNumber,
    );

    _travelCompanyCtrl = TextEditingController(
      text: widget.busViewModel.travelCompany,
    );

    _departureGateCtrl = TextEditingController(
      text: widget.busViewModel.departureGate,
    );

    _departureDateTimeCtrl = TextEditingController(
      text: _formatDate(widget.busViewModel.departureDateTime),
    );

    _busStationNameCtrl = TextEditingController(
      text: widget.busViewModel.busStationName,
    );

    _descriptionCtrl = TextEditingController(
      text: widget.busViewModel.description,
    );

    _detailsCtrl = TextEditingController(
      text: widget.busViewModel.details ?? '',
    );

    _formState = BusFormState(
      travelNumber: FieldState(
        value: widget.busViewModel.travelNumber,
      ),

      travelCompany: FieldState(
        value: widget.busViewModel.travelCompany,
      ),

      departureGate: FieldState(
        value: widget.busViewModel.departureGate,
      ),

      departureDateTime: FieldState(
        value: widget.busViewModel.departureDateTime,
      ),

      busStationName: FieldState(
        value: widget.busViewModel.busStationName,
      ),

      description: FieldState(
        value: widget.busViewModel.description,
      ),

      details: FieldState(
        value: widget.busViewModel.details,
      ),
    );
  }

  @override
  void dispose() {
    _travelNumberCtrl.dispose();
    _travelCompanyCtrl.dispose();
    _departureGateCtrl.dispose();
    _departureDateTimeCtrl.dispose();
    _busStationNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _detailsCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),

      child: Column(
        children: [

          /// Travel number
          CustomFormField.text(
            label: 'Travel Number',
            enabled: true,
            controller: _travelNumberCtrl,
            errorText: _showError(_formState.travelNumber),
            onChanged: _onTravelNumberChanged,
          ),

          const SizedBox(height: 12),

          /// Travel company
          CustomFormField.text(
            label: 'Travel Company',
            enabled: true,
            controller: _travelCompanyCtrl,
            errorText: _showError(_formState.travelCompany),
            onChanged: _onTravelCompanyChanged,
          ),

          const SizedBox(height: 12),

          /// Departure gate
          CustomFormField.text(
            label: 'Departure Gate',
            enabled: true,
            controller: _departureGateCtrl,
            errorText: _showError(_formState.departureGate),
            onChanged: _onDepartureGateChanged,
          ),

          const SizedBox(height: 12),

          /// Departure date
          CustomFormField.date(
            label: 'Departure Date',
            enabled: true,
            controller: _departureDateTimeCtrl,
            errorText: _showError(_formState.departureDateTime),
            onTap: _selectDepartureDate,
          ),

          const SizedBox(height: 12),

          /// Bus station
          CustomFormField.text(
            label: 'Bus Station',
            enabled: true,
            controller: _busStationNameCtrl,
            errorText: _showError(_formState.busStationName),
            onChanged: _onBusStationNameChanged,
          ),

          const SizedBox(height: 12),

          /// Description
          CustomFormField.text(
            label: 'Description',
            enabled: true,
            controller: _descriptionCtrl,
            errorText: _showError(_formState.description),
            onChanged: _onDescriptionChanged,
          ),

          const SizedBox(height: 12),

          /// Optional details
          CustomFormField.text(
            label: 'Details (Optional)',
            enabled: true,
            controller: _detailsCtrl,
            errorText: null,
            onChanged: _onDetailsChanged,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FIELD HANDLERS
  // =========================================================

  void _onTravelNumberChanged(String value) {
    _updateStringField(
      value: value,
      currentField: _formState.travelNumber,
      updater: (field) => _formState = _formState.copyWith(
        travelNumber: field,
      ),
      errorMessage: 'Travel number is required',
    );
  }

  void _onTravelCompanyChanged(String value) {
    _updateStringField(
      value: value,
      currentField: _formState.travelCompany,
      updater: (field) => _formState = _formState.copyWith(
        travelCompany: field,
      ),
      errorMessage: 'Travel company is required',
    );
  }

  void _onDepartureGateChanged(String value) {
    _updateStringField(
      value: value,
      currentField: _formState.departureGate,
      updater: (field) => _formState = _formState.copyWith(
        departureGate: field,
      ),
      errorMessage: 'Departure gate is required',
    );
  }

  void _onBusStationNameChanged(String value) {
    _updateStringField(
      value: value,
      currentField: _formState.busStationName,
      updater: (field) => _formState = _formState.copyWith(
        busStationName: field,
      ),
      errorMessage: 'Bus station name is required',
    );
  }

  void _onDescriptionChanged(String value) {
    _updateStringField(
      value: value,
      currentField: _formState.description,
      updater: (field) => _formState = _formState.copyWith(
        description: field,
      ),
      errorMessage: 'Description is required',
    );
  }

  void _onDetailsChanged(String value) {

    setState(() {
      _formState = _formState.copyWith(
        details: _formState.details.copyWith(
          value: value,
          error: null,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  // =========================================================
  // DATE
  // =========================================================

  Future<void> _selectDepartureDate() async {

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _formState.departureDateTime.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if(selectedDate == null){
      return;
    }

    _departureDateTimeCtrl.text = _formatDate(selectedDate);

    setState(() {
      _formState = _formState.copyWith(
        departureDateTime: _formState.departureDateTime.copyWith(
          value: selectedDate,
          error: null,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  // =========================================================
  // HELPERS
  // =========================================================

  void _updateStringField({
    required String value,
    required FieldState<String> currentField,
    required void Function(FieldState<String>) updater,
    required String errorMessage,
  }) {

    final error = value.trim().isEmpty
        ? errorMessage
        : null;

    setState(() {

      updater(
        currentField.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _emitIfValid() {

    if(!_formState.isValid){
      return;
    }

    final updatedViewModel = TransportViewModel.newBus(
      travelNumber: _formState.travelNumber.value,
      travelCompany: _formState.travelCompany.value,
      departureGate: _formState.departureGate.value,
      departureDateTime: _formState.departureDateTime.value,
      busStationName: _formState.busStationName.value,
      description: _formState.description.value,
      details: _formState.details.value,
    ) as BusViewModel;

    widget.onChanged(updatedViewModel);
  }

  String? _showError(FieldState field) {

    if(!field.isTouched){
      return null;
    }

    return field.error;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}


/// Represents the state of the [BusForm]
class BusFormState {
  final FieldState<String> travelNumber;
  final FieldState<String> travelCompany;
  final FieldState<String> departureGate;
  final FieldState<DateTime> departureDateTime;
  final FieldState<String> busStationName;
  final FieldState<String> description;

  /// Optional field
  final FieldState<String?> details;

  bool get isValid =>
      travelNumber.isValid &&
          travelCompany.isValid &&
          departureGate.isValid &&
          departureDateTime.isValid &&
          busStationName.isValid &&
          description.isValid &&
          details.isValid;

  const BusFormState({
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  });

  BusFormState copyWith({
    FieldState<String>? travelNumber,
    FieldState<String>? travelCompany,
    FieldState<String>? departureGate,
    FieldState<DateTime>? departureDateTime,
    FieldState<String>? busStationName,
    FieldState<String>? description,
    FieldState<String?>? details,
  }) {
    return BusFormState(
      travelNumber: travelNumber ?? this.travelNumber,
      travelCompany: travelCompany ?? this.travelCompany,
      departureGate: departureGate ?? this.departureGate,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      busStationName: busStationName ?? this.busStationName,
      description: description ?? this.description,
      details: details ?? this.details,
    );
  }
}