// ponytail: hand-rolled month abbreviations instead of intl's DateFormat —
// DateFormat needs initializeDateFormatting() per locale, unused anywhere
// else in this app; wiring it up for two date labels isn't worth the setup.
// Upgrade: switch to DateFormat if a third locale-aware date format shows up.
const _monthAbbreviationsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];
const _monthAbbreviationsPt = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez', //
];

/// Abbreviated month name (1-12) for the given locale — `pt` gets the
/// Portuguese short forms, everything else falls back to English.
String monthAbbreviation(String languageCode, int month) {
  final names = languageCode == 'pt' ? _monthAbbreviationsPt : _monthAbbreviationsEn;
  return names[month - 1];
}

/// A date range as "d–d MMM" when both dates fall in the same month/year,
/// or "d MMM–d MMM" otherwise — e.g. "12–19 Oct" / "12 Oct–3 Nov".
String formatDateRange(String languageCode, DateTime start, DateTime end) {
  final endLabel = '${end.day} ${monthAbbreviation(languageCode, end.month)}';
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–$endLabel';
  }
  final startLabel = '${start.day} ${monthAbbreviation(languageCode, start.month)}';
  return '$startLabel–$endLabel';
}

/// A single date as "d MMM yyyy" — e.g. "12 Oct 2026".
String formatDate(String languageCode, DateTime date) =>
    '${date.day} ${monthAbbreviation(languageCode, date.month)} ${date.year}';

/// A time of day as "HH:mm" — e.g. "09:00". Always 24h, locale-independent.
String formatTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
