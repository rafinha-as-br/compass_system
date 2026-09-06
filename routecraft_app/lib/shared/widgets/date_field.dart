import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';

/// Tappable field showing a chosen date (or "—" when none yet), styled like
/// a text field — shared by every screen that lets the client pick a date
/// (route creation, route editing) instead of each one re-declaring the same
/// `InkWell` + `InputDecorator` shell.
class DateField extends StatelessWidget {
  const DateField({super.key, required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: TravelAppColors.textSecondary),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(borderSide: BorderSide(color: TravelAppColors.border)),
        ),
        child: Text(
          date != null ? formatDate(Localizations.localeOf(context).languageCode, date!) : '—',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
