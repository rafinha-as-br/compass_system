import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

/// Form widget for editing a TravelSegment step.
class TravelSegmentFormWidget extends StatefulWidget {
  final TravelSegment segment;
  final ValueChanged<TravelSegment> onChanged;
  final VoidCallback onDelete;

  const TravelSegmentFormWidget({
    super.key,
    required this.segment,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<TravelSegmentFormWidget> createState() =>
      _TravelSegmentFormWidgetState();
}

class _TravelSegmentFormWidgetState extends State<TravelSegmentFormWidget> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _startPointCtrl;
  late final TextEditingController _finishPointCtrl;
  late DateTime _startDate;
  late DateTime _finishDate;
  late String _transportType;

  // Airplane controllers
  late final TextEditingController _flightNumberCtrl;
  late final TextEditingController _flightCompanyCtrl;
  late final TextEditingController _departureGateCtrl;
  late final TextEditingController _departureAirportCtrl;
  late final TextEditingController _arrivalAirportCtrl;

  // Bus controllers
  late final TextEditingController _busTravelNumberCtrl;
  late final TextEditingController _busTravelCompanyCtrl;
  late final TextEditingController _busDepartureGateCtrl;
  late final TextEditingController _busStationNameCtrl;
  late final TextEditingController _busDescriptionCtrl;

  // RentalCar controllers
  late final TextEditingController _vehicleModelCtrl;
  late final TextEditingController _vehiclePlateCtrl;
  late final TextEditingController _rentalCompanyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.segment.title);
    _startPointCtrl = TextEditingController(text: widget.segment.startPoint);
    _finishPointCtrl = TextEditingController(text: widget.segment.finishPoint);
    _startDate = widget.segment.startDate;
    _finishDate = widget.segment.finishDate;

    _transportType = _resolveTransportType(widget.segment.transport);

    // Initialize transport controllers
    _flightNumberCtrl = TextEditingController();
    _flightCompanyCtrl = TextEditingController();
    _departureGateCtrl = TextEditingController();
    _departureAirportCtrl = TextEditingController();
    _arrivalAirportCtrl = TextEditingController();
    _busTravelNumberCtrl = TextEditingController();
    _busTravelCompanyCtrl = TextEditingController();
    _busDepartureGateCtrl = TextEditingController();
    _busStationNameCtrl = TextEditingController();
    _busDescriptionCtrl = TextEditingController();
    _vehicleModelCtrl = TextEditingController();
    _vehiclePlateCtrl = TextEditingController();
    _rentalCompanyCtrl = TextEditingController();

    _loadTransportData(widget.segment.transport);
  }

  String _resolveTransportType(Transport transport) {
    if (transport is Airplane) return 'airplane';
    if (transport is Bus) return 'bus';
    if (transport is RentalCar) return 'rental_car';
    return 'airplane';
  }

  void _loadTransportData(Transport transport) {
    if (transport is Airplane) {
      _flightNumberCtrl.text = transport.flightNumber;
      _flightCompanyCtrl.text = transport.flightCompany;
      _departureGateCtrl.text = transport.departureGate;
      _departureAirportCtrl.text = transport.departureAirport;
      _arrivalAirportCtrl.text = transport.arrivalAirport;
    } else if (transport is Bus) {
      _busTravelNumberCtrl.text = transport.travelNumber;
      _busTravelCompanyCtrl.text = transport.travelCompany;
      _busDepartureGateCtrl.text = transport.departureGate;
      _busStationNameCtrl.text = transport.busStationName;
      _busDescriptionCtrl.text = transport.description;
    } else if (transport is RentalCar) {
      _vehicleModelCtrl.text = transport.vehicleModelName;
      _vehiclePlateCtrl.text = transport.vehicleLicensePlate;
      _rentalCompanyCtrl.text = transport.companyName;
    }
  }

  @override
  void didUpdateWidget(covariant TravelSegmentFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segment.id != widget.segment.id) {
      _titleCtrl.text = widget.segment.title;
      _startPointCtrl.text = widget.segment.startPoint;
      _finishPointCtrl.text = widget.segment.finishPoint;
      _startDate = widget.segment.startDate;
      _finishDate = widget.segment.finishDate;
      _transportType = _resolveTransportType(widget.segment.transport);
      _loadTransportData(widget.segment.transport);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _startPointCtrl.dispose();
    _finishPointCtrl.dispose();
    _flightNumberCtrl.dispose();
    _flightCompanyCtrl.dispose();
    _departureGateCtrl.dispose();
    _departureAirportCtrl.dispose();
    _arrivalAirportCtrl.dispose();
    _busTravelNumberCtrl.dispose();
    _busTravelCompanyCtrl.dispose();
    _busDepartureGateCtrl.dispose();
    _busStationNameCtrl.dispose();
    _busDescriptionCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    _rentalCompanyCtrl.dispose();
    super.dispose();
  }

  Transport _buildTransport() {
    final now = DateTime.now();
    final id = widget.segment.transport.id;

    switch (_transportType) {
      case 'airplane':
        return Airplane(
          id: id,
          flightNumber: _flightNumberCtrl.text,
          flightCompany: _flightCompanyCtrl.text,
          flightDate: _startDate,
          departureGate: _departureGateCtrl.text,
          departureAirport: _departureAirportCtrl.text,
          arrivalAirport: _arrivalAirportCtrl.text,
        );
      case 'bus':
        return Bus(
          id: id,
          travelNumber: _busTravelNumberCtrl.text,
          travelCompany: _busTravelCompanyCtrl.text,
          departureGate: _busDepartureGateCtrl.text,
          departureDateTime: _startDate,
          busStationName: _busStationNameCtrl.text,
          description: _busDescriptionCtrl.text,
          details: null,
        );
      case 'rental_car':
        return RentalCar(
          id: id,
          vehicleModelName: _vehicleModelCtrl.text,
          vehicleLicensePlate: _vehiclePlateCtrl.text,
          companyName: _rentalCompanyCtrl.text,
          checkInDate: _startDate,
          checkOutDate: _finishDate,
        );
      default:
        return Airplane(
          id: id,
          flightNumber: '',
          flightCompany: '',
          flightDate: now,
          departureGate: '',
          departureAirport: '',
          arrivalAirport: '',
        );
    }
  }

  void _emitChange() {
    widget.onChanged(TravelSegment(
      id: widget.segment.id,
      title: _titleCtrl.text,
      startDate: _startDate,
      finishDate: _finishDate,
      travelSegmentId: widget.segment.travelSegmentId,
      transport: _buildTransport(),
      startPoint: _startPointCtrl.text,
      finishPoint: _finishPointCtrl.text,
    ));
  }

  Future<void> _pickDate({
    required DateTime current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
      _emitChange();
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Segment',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Step Title',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startPointCtrl,
                decoration: const InputDecoration(
                  labelText: 'Start Point',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _emitChange(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _finishPointCtrl,
                decoration: const InputDecoration(
                  labelText: 'Finish Point',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _emitChange(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(
                  current: _startDate,
                  onPicked: (d) => _startDate = d,
                ),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('Start: ${_formatDate(_startDate)}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(
                  current: _finishDate,
                  onPicked: (d) => _finishDate = d,
                ),
                icon: const Icon(Icons.event, size: 16),
                label: Text('End: ${_formatDate(_finishDate)}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Transport Type',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'airplane', label: Text('Airplane')),
            ButtonSegment(value: 'bus', label: Text('Bus')),
            ButtonSegment(value: 'rental_car', label: Text('Rental Car')),
          ],
          selected: {_transportType},
          onSelectionChanged: (selected) {
            setState(() => _transportType = selected.first);
            _emitChange();
          },
        ),
        const SizedBox(height: 16),
        _buildTransportFields(theme),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: widget.onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Step'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportFields(ThemeData theme) {
    switch (_transportType) {
      case 'airplane':
        return Column(
          children: [
            TextField(
              controller: _flightNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Flight Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _flightCompanyCtrl,
              decoration: const InputDecoration(
                labelText: 'Airline Company',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _departureGateCtrl,
              decoration: const InputDecoration(
                labelText: 'Departure Gate',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _departureAirportCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Departure Airport',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _emitChange(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _arrivalAirportCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Arrival Airport',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _emitChange(),
                  ),
                ),
              ],
            ),
          ],
        );
      case 'bus':
        return Column(
          children: [
            TextField(
              controller: _busTravelNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Travel Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _busTravelCompanyCtrl,
              decoration: const InputDecoration(
                labelText: 'Travel Company',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busDepartureGateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Departure Gate',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _emitChange(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _busStationNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bus Station',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _emitChange(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _busDescriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
          ],
        );
      case 'rental_car':
        return Column(
          children: [
            TextField(
              controller: _vehicleModelCtrl,
              decoration: const InputDecoration(
                labelText: 'Vehicle Model',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vehiclePlateCtrl,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rentalCompanyCtrl,
              decoration: const InputDecoration(
                labelText: 'Rental Company',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _emitChange(),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
