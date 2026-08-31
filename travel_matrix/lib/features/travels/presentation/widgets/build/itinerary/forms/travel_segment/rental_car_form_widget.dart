import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/field_state.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

import '../../../../../../../../shared/widgets/text_fields.dart';

/// Form for editing a [RentalCarViewModel], receives the [RentalCarViewModel] and a callback to update it
class RentalCarForm extends StatefulWidget {
  const RentalCarForm({
    super.key,
    required this.rentalCar,
    required this.onChanged,
  });

  /// The entity to edit
  final RentalCarViewModel rentalCar;

  /// Callback triggered only when the form is valid
  final void Function(RentalCarViewModel rentalCar) onChanged;

  @override
  State<RentalCarForm> createState() => _RentalCarFormState();
}

class _RentalCarFormState extends State<RentalCarForm> {

  late final TextEditingController _vehicleModelCtrl;
  late final TextEditingController _vehicleLicensePlateCtrl;
  late final TextEditingController _companyNameCtrl;
  late final TextEditingController _checkInDateCtrl;
  late final TextEditingController _checkOutDateCtrl;

  late RentalCarFormState _formState;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();

    _vehicleModelCtrl = TextEditingController(
      text: widget.rentalCar.vehicleModelName,
    );

    _vehicleLicensePlateCtrl = TextEditingController(
      text: widget.rentalCar.vehicleLicensePlate,
    );

    _companyNameCtrl = TextEditingController(
      text: widget.rentalCar.companyName,
    );

    _checkInDateCtrl = TextEditingController(
      text: _dateFormat.format(widget.rentalCar.checkInDate),
    );

    _checkOutDateCtrl = TextEditingController(
      text: _dateFormat.format(widget.rentalCar.checkOutDate),
    );

    _formState = RentalCarFormState(
      vehicleModelName: FieldState(
        value: widget.rentalCar.vehicleModelName,
      ),
      vehicleLicensePlate: FieldState(
        value: widget.rentalCar.vehicleLicensePlate,
      ),
      companyName: FieldState(
        value: widget.rentalCar.companyName,
      ),
      checkInDate: FieldState(
        value: widget.rentalCar.checkInDate,
      ),
      checkOutDate: FieldState(
        value: widget.rentalCar.checkOutDate,
      ),
    );
  }

  @override
  void dispose() {
    _vehicleModelCtrl.dispose();
    _vehicleLicensePlateCtrl.dispose();
    _companyNameCtrl.dispose();
    _checkInDateCtrl.dispose();
    _checkOutDateCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      child: Column(
        children: [

          Row(
            children: [

              Expanded(
                child: CustomFormField.text(
                  label: l10n.vehicleModelLabel,
                  enabled: true,
                  controller: _vehicleModelCtrl,
                  errorText: _showError(
                    _formState.vehicleModelName,
                  ),
                  onChanged: _onVehicleModelChanged,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: CustomFormField.text(
                  label: l10n.licensePlateLabel,
                  enabled: true,
                  controller: _vehicleLicensePlateCtrl,
                  errorText: _showError(
                    _formState.vehicleLicensePlate,
                  ),
                  onChanged: _onVehicleLicensePlateChanged,
                ),
              ),

            ],
          ),

          const SizedBox(height: 12),

          CustomFormField.text(
            label: l10n.companyNameLabel,
            enabled: true,
            controller: _companyNameCtrl,
            errorText: _showError(
              _formState.companyName,
            ),
            onChanged: _onCompanyNameChanged,
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: CustomFormField.date(
                  label: l10n.checkInDateLabel,
                  enabled: true,
                  controller: _checkInDateCtrl,
                  errorText: _showError(
                    _formState.checkInDate,
                  ),
                  onTap: _selectCheckInDate,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: CustomFormField.date(
                  label: l10n.checkOutDateLabel,
                  enabled: true,
                  controller: _checkOutDateCtrl,
                  errorText: _showError(
                    _formState.checkOutDate,
                  ),
                  onTap: _selectCheckOutDate,
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  String? _showError(FieldState field) {
    if (!field.isTouched) {
      return null;
    }

    return field.error;
  }

  void _onVehicleModelChanged(String value) {
    final error = value.trim().isEmpty
        ? AppLocalizations.of(context)!.vehicleModelRequiredValidation
        : null;

    setState(() {
      _formState = _formState.copyWith(
        vehicleModelName: _formState.vehicleModelName.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _onVehicleLicensePlateChanged(String value) {
    final error = value.trim().isEmpty
        ? AppLocalizations.of(context)!.licensePlateRequiredValidation
        : null;

    setState(() {
      _formState = _formState.copyWith(
        vehicleLicensePlate: _formState.vehicleLicensePlate.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  void _onCompanyNameChanged(String value) {
    final error = value.trim().isEmpty
        ? AppLocalizations.of(context)!.companyNameRequiredValidation
        : null;

    setState(() {
      _formState = _formState.copyWith(
        companyName: _formState.companyName.copyWith(
          value: value,
          error: error,
          isTouched: true,
        ),
      );
    });

    _emitIfValid();
  }

  Future<void> _selectCheckInDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _formState.checkInDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return;
    }

    _checkInDateCtrl.text = _dateFormat.format(date);

    final error = _formState.checkOutDate.value.isBefore(date)
        ? AppLocalizations.of(context)!.checkInAfterCheckOutError
        : null;

    setState(() {
      _formState = _formState.copyWith(
        checkInDate: _formState.checkInDate.copyWith(
          value: date,
          error: error,
          isTouched: true,
        ),

        checkOutDate: _formState.checkOutDate.copyWith(
          error: error,
        ),
      );
    });

    _emitIfValid();
  }

  Future<void> _selectCheckOutDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _formState.checkOutDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return;
    }

    _checkOutDateCtrl.text = _dateFormat.format(date);

    final error = date.isBefore(_formState.checkInDate.value)
        ? AppLocalizations.of(context)!.checkOutBeforeCheckInError
        : null;

    setState(() {
      _formState = _formState.copyWith(
        checkOutDate: _formState.checkOutDate.copyWith(
          value: date,
          error: error,
          isTouched: true,
        ),

        checkInDate: _formState.checkInDate.copyWith(
          error: error,
        ),
      );
    });

    _emitIfValid();
  }

  void _emitIfValid() {
    if (!_formState.isValid) {
      return;
    }

    widget.onChanged(
      TransportViewModel.newRentalCar(
        vehicleModelName: _formState.vehicleModelName.value,
        vehicleLicensePlate: _formState.vehicleLicensePlate.value,
        companyName: _formState.companyName.value,
        checkInDate: _formState.checkInDate.value,
        checkOutDate: _formState.checkOutDate.value,
      ) as RentalCarViewModel,
    );
  }
}

class RentalCarFormState {

  final FieldState<String> vehicleModelName;
  final FieldState<String> vehicleLicensePlate;
  final FieldState<String> companyName;
  final FieldState<DateTime> checkInDate;
  final FieldState<DateTime> checkOutDate;

  const RentalCarFormState({
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  });

  bool get isValid {
    return vehicleModelName.isValid &&
        vehicleLicensePlate.isValid &&
        companyName.isValid &&
        checkInDate.isValid &&
        checkOutDate.isValid;
  }

  RentalCarFormState copyWith({
    FieldState<String>? vehicleModelName,
    FieldState<String>? vehicleLicensePlate,
    FieldState<String>? companyName,
    FieldState<DateTime>? checkInDate,
    FieldState<DateTime>? checkOutDate,
  }) {
    return RentalCarFormState(
      vehicleModelName:
      vehicleModelName ?? this.vehicleModelName,

      vehicleLicensePlate:
      vehicleLicensePlate ?? this.vehicleLicensePlate,

      companyName:
      companyName ?? this.companyName,

      checkInDate:
      checkInDate ?? this.checkInDate,

      checkOutDate:
      checkOutDate ?? this.checkOutDate,
    );
  }
}