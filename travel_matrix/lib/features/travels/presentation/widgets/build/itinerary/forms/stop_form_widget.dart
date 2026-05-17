import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

/// Form widget for editing a Stop step.
/// TODO: Review the implementation of all theses text editing controllers into a separated file
/// This widget must receive the view model class, callback actions from the edit controller and have an own controller for it,
/// Ask chatgpt how to improve this UI
class StopFormWidget extends StatefulWidget {
  final Stop stop;
  final ValueChanged<Stop> onChanged;
  final VoidCallback onDelete;

  const StopFormWidget({
    super.key,
    required this.stop,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<StopFormWidget> createState() => _StopFormWidgetState();
}

class _StopFormWidgetState extends State<StopFormWidget> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _experienceCtrl;
  late final List<String> _experiences;
  late DateTime _startDate;
  late DateTime _finishDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.stop.title);
    _nameCtrl = TextEditingController(text: widget.stop.name);
    _descCtrl = TextEditingController(text: widget.stop.description);
    _experienceCtrl = TextEditingController();
    _experiences = List.from(widget.stop.experiences);
    _startDate = widget.stop.startDate;
    _finishDate = widget.stop.finishDate;
  }

  @override
  void didUpdateWidget(covariant StopFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stop.id != widget.stop.id) {
      _titleCtrl.text = widget.stop.title;
      _nameCtrl.text = widget.stop.name;
      _descCtrl.text = widget.stop.description;
      _experiences
        ..clear()
        ..addAll(widget.stop.experiences);
      _startDate = widget.stop.startDate;
      _finishDate = widget.stop.finishDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(Stop(
      id: widget.stop.id,
      title: _titleCtrl.text,
      startDate: _startDate,
      finishDate: _finishDate,
      name: _nameCtrl.text,
      description: _descCtrl.text,
      experiences: List.from(_experiences),
      finished: widget.stop.finished,
    ));
  }

  void _addExperience() {
    if (_experienceCtrl.text.isNotEmpty) {
      setState(() {
        _experiences.add(_experienceCtrl.text);
        _experienceCtrl.clear();
      });
      _emitChange();
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _finishDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _finishDate = picked;
        }
      });
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
          'Stop',
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
            labelText: 'Stop Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(isStart: true),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('Start: ${_formatDate(_startDate)}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(isStart: false),
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
              child: TextField(
                controller: _experienceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Add Experience',
                  border: OutlineInputBorder(),
                ),
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
          children: _experiences
              .map((e) => Chip(
                    label: Text(e, style: const TextStyle(fontSize: 12)),
                    onDeleted: () {
                      setState(() => _experiences.remove(e));
                      _emitChange();
                    },
                  ))
              .toList(),
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
