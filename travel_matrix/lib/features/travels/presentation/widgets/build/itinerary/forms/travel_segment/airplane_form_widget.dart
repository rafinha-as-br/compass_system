import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/field_state.dart';

import '../../../../../../../../shared/widgets/text_fields.dart';

/// Airplane form widget, receives the [AirplaneViewModel] and a callback to update it
class AirplaneForm extends StatefulWidget {
  const AirplaneForm({
    super.key,
    required this.airplaneViewModel,
    required this.onChanged,
  });

  final AirplaneViewModel airplaneViewModel;

  /// Called ONLY when form is valid
  final ValueChanged<AirplaneViewModel> onChanged;

  @override
  State<AirplaneForm> createState() => _AirplaneFormState();
}

class _AirplaneFormState extends State<AirplaneForm> {

  late final TextEditingController _flightNumberCtrl;
  late final TextEditingController _flightCompanyCtrl;
  late final TextEditingController _flightDateCtrl;
  late final TextEditingController _departureGateCtrl;
  late final TextEditingController _departureAirportCtrl;
  late final TextEditingController _arrivalAirportCtrl;

  late AirplaneFormState _formState;

  @override
  void initState() {
    super.initState();

    _flightNumberCtrl = TextEditingController(
      text: widget.airplaneViewModel.flightNumber,
    );

    _flightCompanyCtrl = TextEditingController(
      text: widget.airplaneViewModel.flightCompany,
    );

    _flightDateCtrl = TextEditingController(
      text: _formatDate(widget.airplaneViewModel.flightDate),
    );

    _departureGateCtrl = TextEditingController(
      text: widget.airplaneViewModel.departureGate,
    );

    _departureAirportCtrl = TextEditingController(
      text: widget.airplaneViewModel.departureAirport,
    );

    _arrivalAirportCtrl = TextEditingController(
      text: widget.airplaneViewModel.arrivalAirport,
    );

    _formState = AirplaneFormState(
      flightNumber: FieldState(
        value: widget.airplaneViewModel.flightNumber,
      ),
      flightCompany: FieldState(
        value: widget.airplaneViewModel.flightCompany,
      ),
      flightDate: FieldState(
        value: widget.airplaneViewModel.flightDate,
      ),
      departureGate: FieldState(
        value: widget.airplaneViewModel.departureGate,
      ),
      departureAirport: FieldState(
        value: widget.airplaneViewModel.departureAirport,
      ),
      arrivalAirport: FieldState(
        value: widget.airplaneViewModel.arrivalAirport,
      ),
    );
  }

  @override
  void dispose() {
    _flightNumberCtrl.dispose();
    _flightCompanyCtrl.dispose();
    _flightDateCtrl.dispose();
    _departureGateCtrl.dispose();
    _departureAirportCtrl.dispose();
    _arrivalAirportCtrl.dispose();

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

          /// Flight number
          CustomFormField.text(
            label: 'Flight Number',
            enabled: true,
            controller: _flightNumberCtrl,
            errorText: _showError(_formState.flightNumber),
            onChanged: _onFlightNumberChanged,
          ),

          const SizedBox(height: 12),

          /// Flight company
          CustomFormField.text(
            label: 'Flight Company',
            enabled: true,
            controller: _flightCompanyCtrl,
            errorText: _showError(_formState.flightCompany),
            onChanged: _onFlightCompanyChanged,
          ),

          const SizedBox(height: 12),

          /// Flight date
          CustomFormField.date(
            label: 'Flight Date',
            enabled: true,
            controller: _flightDateCtrl,
            errorText: _showError(_formState.flightDate),
            onTap: _selectFlightDate,
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

          Row(
            children: [

              Expanded(
                child: CustomFormField.text(
                  label: 'Departure Airport',
                  enabled: true,
                  controller: _departureAirportCtrl,
                  errorText: _showError(_formState.departureAirport),
                  onChanged: _onDepartureAirportChanged,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: CustomFormField.text(
                  label: 'Arrival Airport',
                  enabled: true,
                  controller: _arrivalAirportCtrl,
                  errorText: _showError(_formState.arrivalAirport),
                  onChanged: _onArrivalAirportChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FIELD HANDLERS
  // =========================================================

  void _onFlightNumberChanged(String value) {
    final error = value.trim().isEmpty
        ? 'Flight number is required'
        : null;

    setState(() {
      _formState = _formState.copyWith(
        flightNumber: _formState.flightNumber.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _onFlightCompanyChanged(String value) {
    final error = value.trim().isEmpty
        ? 'Flight company is required'
        : null;

    setState(() {
      _formState = _formState.copyWith(
        flightCompany: _formState.flightCompany.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _onDepartureGateChanged(String value) {
    final error = value.trim().isEmpty
        ? 'Departure gate is required'
        : null;

    setState(() {
      _formState = _formState.copyWith(
        departureGate: _formState.departureGate.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _onDepartureAirportChanged(String value) {
    final error = value.trim().isEmpty
        ? 'Departure airport is required'
        : null;

    setState(() {
      _formState = _formState.copyWith(
        departureAirport: _formState.departureAirport.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _onArrivalAirportChanged(String value) {
    final error = value.trim().isEmpty
        ? 'Arrival airport is required'
        : null;

    setState(() {
      _formState = _formState.copyWith(
        arrivalAirport: _formState.arrivalAirport.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  // =========================================================
  // DATE
  // =========================================================

  Future<void> _selectFlightDate() async {

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _formState.flightDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if(selectedDate == null){
      return;
    }

    _flightDateCtrl.text = _formatDate(selectedDate);

    setState(() {
      _formState = _formState.copyWith(
        flightDate: _formState.flightDate.copyWith(
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

  void _emitIfValid() {

    if(!_formState.isValid){
      return;
    }

    final updatedViewModel = TransportViewModel.newAirplane(
      flightNumber: _formState.flightNumber.value,
      flightCompany: _formState.flightCompany.value,
      flightDate: _formState.flightDate.value,
      departureGate: _formState.departureGate.value,
      departureAirport: _formState.departureAirport.value,
      arrivalAirport: _formState.arrivalAirport.value,
    ) as AirplaneViewModel;

    widget.onChanged(updatedViewModel);
  }

  String? _showError(FieldState field){

    if(!field.isTouched){
      return null;
    }

    return field.error;
  }

  String _formatDate(DateTime date){
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

/// Represents the state of the [AirplaneForm]
class AirplaneFormState {
  final FieldState<String> flightNumber;
  final FieldState<String> flightCompany;
  final FieldState<DateTime> flightDate;
  final FieldState<String> departureGate;
  final FieldState<String> departureAirport;
  final FieldState<String> arrivalAirport;

  bool get isValid =>
      flightNumber.isValid &&
          flightCompany.isValid &&
          flightDate.isValid &&
          departureGate.isValid &&
          departureAirport.isValid &&
          arrivalAirport.isValid;

  const AirplaneFormState({
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  AirplaneFormState copyWith({
    FieldState<String>? flightNumber,
    FieldState<String>? flightCompany,
    FieldState<DateTime>? flightDate,
    FieldState<String>? departureGate,
    FieldState<String>? departureAirport,
    FieldState<String>? arrivalAirport,
  }) {
    return AirplaneFormState(
      flightNumber: flightNumber ?? this.flightNumber,
      flightCompany: flightCompany ?? this.flightCompany,
      flightDate: flightDate ?? this.flightDate,
      departureGate: departureGate ?? this.departureGate,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
    );
  }
}