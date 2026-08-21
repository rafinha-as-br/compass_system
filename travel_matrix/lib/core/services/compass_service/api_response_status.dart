/// The `status` value the compass-api backend uses in its JSON envelope
/// (`{status, data, message}`) to indicate a successful response. Compared
/// against `response['status']` throughout the presentation layer instead
/// of repeating the `'success'` literal, so a typo can't silently break
/// success detection.
const String kApiSuccessStatus = 'success';
