/// Shared ISO-8601 date parsing for the travels DTOs — used wherever a
/// field has a natural anchor date to fall back to when missing/malformed
/// (e.g. a step's `finishDate` falling back to its own `startDate`).
DateTime parseIsoDate(dynamic value, {DateTime? fallback}) {
  return DateTime.tryParse(value?.toString() ?? '') ?? fallback ?? DateTime.now();
}
