import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

/// Form widget for editing a Hosting step.
///
/// TODO: Review the implementation of all theses text editing controllers into a separated file
/// This widget must receive the view model class, callback actions from the edit controller and have an own controller for it,
/// Ask chatgpt how to improve this UI
class HostingFormWidget extends StatefulWidget {
  final Hosting hosting;
  final ValueChanged<Hosting> onChanged;
  final VoidCallback onDelete;

  const HostingFormWidget({
    super.key,
    required this.hosting,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<HostingFormWidget> createState() => _HostingFormWidgetState();
}

class _HostingFormWidgetState extends State<HostingFormWidget> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late DateTime _startDate;
  late DateTime _finishDate;
  late DateTime _checkIn;
  late DateTime _checkOut;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.hosting.title);
    _nameCtrl = TextEditingController(text: widget.hosting.name);
    _addressCtrl = TextEditingController(text: widget.hosting.address);
    _startDate = widget.hosting.startDate;
    _finishDate = widget.hosting.finishDate;
    _checkIn = widget.hosting.checkIn;
    _checkOut = widget.hosting.checkOut;
  }

  @override
  void didUpdateWidget(covariant HostingFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hosting.id != widget.hosting.id) {
      _titleCtrl.text = widget.hosting.title;
      _nameCtrl.text = widget.hosting.name;
      _addressCtrl.text = widget.hosting.address;
      _startDate = widget.hosting.startDate;
      _finishDate = widget.hosting.finishDate;
      _checkIn = widget.hosting.checkIn;
      _checkOut = widget.hosting.checkOut;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(Hosting(
      id: widget.hosting.id,
      title: _titleCtrl.text,
      startDate: _startDate,
      finishDate: _finishDate,
      name: _nameCtrl.text,
      address: _addressCtrl.text,
      checkIn: _checkIn,
      checkOut: _checkOut,
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
          'Hosting',
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
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Hosting Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressCtrl,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emitChange(),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(
                  current: _checkIn,
                  onPicked: (d) => _checkIn = d,
                ),
                icon: const Icon(Icons.login, size: 16),
                label: Text('Check-in: ${_formatDate(_checkIn)}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(
                  current: _checkOut,
                  onPicked: (d) => _checkOut = d,
                ),
                icon: const Icon(Icons.logout, size: 16),
                label: Text('Check-out: ${_formatDate(_checkOut)}'),
              ),
            ),
          ],
        ),
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
}
