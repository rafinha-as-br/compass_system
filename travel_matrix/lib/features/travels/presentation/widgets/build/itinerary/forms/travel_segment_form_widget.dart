import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment/airplane_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment/bus_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment/rental_car_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/change_type_dialog.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

import '../../../../../../../shared/widgets/text_fields.dart';
import 'field_state.dart';

class TravelSegmentFormWidget extends StatefulWidget {
  const TravelSegmentFormWidget({
    super.key,
    required this.segment,
    required this.onChanged,
    required this.onDelete,
  });

  final TravelSegmentStepViewModel segment;
  final ValueChanged<TravelSegmentStepViewModel> onChanged;
  final VoidCallback onDelete;

  @override
  State<TravelSegmentFormWidget> createState() =>
      _TravelSegmentFormWidgetState();
}

class _TravelSegmentFormWidgetState extends State<TravelSegmentFormWidget> {
  late final TextEditingController _startPointCtrl;
  late final TextEditingController _finishPointCtrl;

  late TravelSegmentFormState _formState;

  @override
  void initState() {
    super.initState();

    _startPointCtrl = TextEditingController(text: widget.segment.startPoint);

    _finishPointCtrl = TextEditingController(text: widget.segment.finishPoint);

    _formState = TravelSegmentFormState(
      startPoint: FieldState(value: widget.segment.startPoint),
      finishPoint: FieldState(value: widget.segment.finishPoint),
      transport: widget.segment.transport,
    );
  }

  @override
  void dispose() {
    _startPointCtrl.dispose();
    _finishPointCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TravelSegmentFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.segment.localId != widget.segment.localId) {
      _startPointCtrl.text = widget.segment.startPoint;
      _finishPointCtrl.text = widget.segment.finishPoint;

      _formState = TravelSegmentFormState(
        startPoint: FieldState(value: widget.segment.startPoint),
        finishPoint: FieldState(value: widget.segment.finishPoint),
        transport: widget.segment.transport,
      );

      setState(() {});
    }
  }

  FieldState<String> _validateRequiredField(BuildContext context, String value) {
    if (value.trim().isEmpty) {
      return FieldState(
        value: value,
        error: AppLocalizations.of(context)!.fieldRequiredError,
        isTouched: true,
      );
    }

    return FieldState(value: value, isTouched: true);
  }

  void _onStartPointChanged(String value) {
    final validatedField = _validateRequiredField(context, value);

    setState(() {
      _formState = _formState.copyWith(startPoint: validatedField);
    });

    _emitIfValid();
  }

  void _onFinishPointChanged(String value) {
    final validatedField = _validateRequiredField(context, value);

    setState(() {
      _formState = _formState.copyWith(finishPoint: validatedField);
    });

    _emitIfValid();
  }

  void _emitIfValid() {
    if (!_formState.isValid) {
      return;
    }

    widget.onChanged(
      widget.segment.copyWith(
        title: widget.segment.title,
        startDate: widget.segment.startDate,
        finishDate: widget.segment.finishDate,
        startPoint: _formState.startPoint.value,
        finishPoint: _formState.finishPoint.value,
        transport: _formState.transport,
      ),
    );
  }

  Future<void> _changeTransportType(String type) async {
    if (type == _selectedTransportType) {
      return;
    }

    if (_formState.transport is! PlaceHolderTransportViewModel) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => const ChangeTransportTypeDialog(),
      );

      if (confirm != true) return;
    }

    late TransportViewModel newTransport;

    switch (type) {
      case 'airplane':
        newTransport = TransportViewModel.newAirplane(
          flightNumber: '',
          flightCompany: '',
          flightDate: DateTime.now(),
          departureGate: '',
          departureAirport: '',
          arrivalAirport: '',
        );
        break;

      case 'bus':
        newTransport = TransportViewModel.newBus(
          travelNumber: '',
          travelCompany: '',
          departureGate: '',
          departureDateTime: DateTime.now(),
          busStationName: '',
          description: '',
          details: null,
        );
        break;

      case 'rental_car':
        newTransport = TransportViewModel.newRentalCar(
          vehicleModelName: '',
          vehicleLicensePlate: '',
          companyName: '',
          checkInDate: DateTime.now(),
          checkOutDate: DateTime.now(),
        );
        break;
    }

    setState(() {
      _formState = _formState.copyWith(transport: newTransport);
    });

    _emitIfValid();
  }

  String get _selectedTransportType {
    if (_formState.transport is AirplaneViewModel) {
      return 'airplane';
    }

    if (_formState.transport is BusViewModel) {
      return 'bus';
    }

    if (_formState.transport is RentalCarViewModel) {
      return 'rental_car';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomFormField.text(
                  label: l10n.startPointLabel,
                  enabled: true,
                  controller: _startPointCtrl,
                  errorText: _formState.startPoint.isTouched
                      ? _formState.startPoint.error
                      : null,
                  onChanged: _onStartPointChanged,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: CustomFormField.text(
                  label: l10n.finishPointLabel,
                  enabled: true,
                  controller: _finishPointCtrl,
                  errorText: _formState.finishPoint.isTouched
                      ? _formState.finishPoint.error
                      : null,
                  onChanged: _onFinishPointChanged,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 16),

          _TransportTypeSelector(
            selectedType: _selectedTransportType,
            onTypeSelected: (value) {
              _changeTransportType(value);
            },
          ),

          const SizedBox(height: 16),

          _buildTransportForm(),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete),
            label: Text(AppLocalizations.of(context)!.deleteStep),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportForm() {
    switch (_formState.transport) {
      case AirplaneViewModel airplane:
        return AirplaneForm(
          airplaneViewModel: airplane,

          onChanged: (updatedAirplane) {
            setState(() {
              _formState = _formState.copyWith(transport: updatedAirplane);
            });

            _emitIfValid();
          },
        );

      case BusViewModel bus:
        return BusForm(
          busViewModel: bus,

          onChanged: (updatedBus) {
            setState(() {
              _formState = _formState.copyWith(transport: updatedBus);
            });

            _emitIfValid();
          },
        );

      case RentalCarViewModel rentalCar:
        return RentalCarForm(
          rentalCar: rentalCar,

          onChanged: (updatedRentalCar) {
            setState(() {
              _formState = _formState.copyWith(transport: updatedRentalCar);
            });

            _emitIfValid();
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Represents the state of the [TravelSegmentFormWidget]
class TravelSegmentFormState {
  final FieldState<String> startPoint;
  final FieldState<String> finishPoint;

  /// Transport already contains its own internal validation
  final TransportViewModel transport;

  bool get isValid => startPoint.isValid && finishPoint.isValid;

  const TravelSegmentFormState({
    required this.startPoint,
    required this.finishPoint,
    required this.transport,
  });

  TravelSegmentFormState copyWith({
    FieldState<String>? startPoint,
    FieldState<String>? finishPoint,
    TransportViewModel? transport,
  }) {
    return TravelSegmentFormState(
      startPoint: startPoint ?? this.startPoint,
      finishPoint: finishPoint ?? this.finishPoint,
      transport: transport ?? this.transport,
    );
  }
}

class _TransportTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const _TransportTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transportTypeLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _TransportCard(
              icon: Icons.flight_takeoff,
              title: l10n.airplaneTransportLabel,
              isSelected: selectedType == 'airplane',
              onTap: () => onTypeSelected('airplane'),
            ),
            _TransportCard(
              icon: Icons.directions_bus,
              title: l10n.busTransportLabel,
              isSelected: selectedType == 'bus',
              onTap: () => onTypeSelected('bus'),
            ),
            _TransportCard(
              icon: Icons.car_rental,
              title: l10n.rentalCarTransportLabel,
              isSelected: selectedType == 'rental_car',
              onTap: () => onTypeSelected('rental_car'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransportCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
