import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/models/place_suggestion.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/skeleton_block.dart';

enum _AutocompleteStatus { idle, loading, results, empty, error }

/// Design System ID: cps.candidate.places-autocomplete-field
///
/// Text field with place suggestions (CPS-154) — debounced search against
/// the `compass-api` facade (CPS-152), returning both the normalized text
/// and the chosen coordinate. Degrades to plain free text, without ever
/// blocking the field, when the search service fails.
///
/// The component never decides where the value is saved — it only reports
/// text + coordinate through [onChanged], on every keystroke (coordinate
/// reset to null) and on every suggestion pick (coordinate populated).
///
/// Candidate component (not yet an official Design System entry) — same ID
/// used in the Claude Design handoff and, once catalogued, in Confluence.
class PlacesAutocompleteField extends StatefulWidget {
  const PlacesAutocompleteField({
    super.key,
    required this.labelText,
    required this.fetchSuggestions,
    required this.onChanged,
    this.initialText,
    this.initialCoordinate,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  final String labelText;
  final Future<List<PlaceSuggestion>> Function(String query) fetchSuggestions;
  final ValueChanged<PlaceAutocompleteResult> onChanged;
  final String? initialText;
  final PlaceCoordinate? initialCoordinate;
  final Duration debounceDuration;

  @override
  State<PlacesAutocompleteField> createState() => _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState extends State<PlacesAutocompleteField> {
  static const _minQueryLength = 2;

  late final TextEditingController _controller = TextEditingController(text: widget.initialText);
  final FocusNode _focusNode = FocusNode();

  Timer? _debounceTimer;
  // Guards against a stale fetch (from an earlier keystroke) overwriting a
  // more recent one that already resolved.
  int _requestId = 0;

  _AutocompleteStatus _status = _AutocompleteStatus.idle;
  List<PlaceSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    // Rebuilds to show/hide the dropdown the moment focus changes (e.g. the
    // user taps away) — hasFocus is read directly in build(), so without
    // this listener that transition would only appear on the next unrelated
    // rebuild.
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    widget.onChanged(PlaceAutocompleteResult(text: text));

    final trimmed = text.trim();
    if (trimmed.length < _minQueryLength) {
      setState(() {
        _status = _AutocompleteStatus.idle;
        _suggestions = const [];
      });
      return;
    }

    _debounceTimer = Timer(widget.debounceDuration, () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    setState(() => _status = _AutocompleteStatus.loading);

    try {
      final results = await widget.fetchSuggestions(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _suggestions = results;
        _status = results.isEmpty ? _AutocompleteStatus.empty : _AutocompleteStatus.results;
      });
    } catch (error) {
      // Degradation, not a swallowed failure: surfaced as the error state
      // below, and logged here so a real outage is still visible in dev/QA.
      debugPrint('PlacesAutocompleteField: fetch failed for "$query": $error');
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _suggestions = const [];
        _status = _AutocompleteStatus.error;
      });
    }
  }

  void _selectSuggestion(PlaceSuggestion suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion.text,
      selection: TextSelection.collapsed(offset: suggestion.text.length),
    );
    setState(() {
      _status = _AutocompleteStatus.idle;
      _suggestions = const [];
    });
    _focusNode.unfocus();
    widget.onChanged(PlaceAutocompleteResult(text: suggestion.text, coordinate: suggestion.coordinate));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final showDropdown = _focusNode.hasFocus &&
        (_status == _AutocompleteStatus.loading ||
            _status == _AutocompleteStatus.results ||
            _status == _AutocompleteStatus.empty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TravelAppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined, size: 16, color: TravelAppColors.textSecondary),
            suffixIcon: _status == _AutocompleteStatus.loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: TravelAppColors.primary),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TravelAppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TravelAppColors.primary),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        // ponytail: dropdown rendered inline (pushes content down) instead of
        // a floating overlay — same anchored-below look the design calls
        // for, without CompositedTransformTarget/OverlayPortal positioning.
        // Upgrade to a real overlay if a screen needs it to float above
        // sibling content instead of shifting it.
        if (showDropdown) _buildDropdown(theme, l10n),
        if (_status == _AutocompleteStatus.error) _buildErrorNotice(theme, l10n),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border.all(color: TravelAppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: switch (_status) {
        _AutocompleteStatus.loading => Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (_) => _buildSkeletonRow()),
          ),
        _AutocompleteStatus.empty => Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              l10n.placesAutocompleteNoResults,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: TravelAppColors.textSecondary),
            ),
          ),
        _AutocompleteStatus.results => Column(
            mainAxisSize: MainAxisSize.min,
            children: _suggestions.map(_buildSuggestionRow).toList(),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildSkeletonRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SkeletonBlock(height: 15, width: 15),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(height: 10, width: 140),
                SizedBox(height: 4),
                SkeletonBlock(height: 8, width: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionRow(PlaceSuggestion suggestion) {
    final parts = suggestion.text.split(',');
    final title = parts.first.trim();
    final subtitle = parts.length > 1 ? parts.sublist(1).join(',').trim() : null;

    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, size: 15, color: TravelAppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: TravelAppColors.textPrimary)),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle, style: const TextStyle(fontSize: 11.5, color: TravelAppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorNotice(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 13, color: TravelAppColors.warning),
          const SizedBox(width: 4),
          Text(l10n.placesAutocompleteUnavailable, style: const TextStyle(fontSize: 11.5, color: TravelAppColors.warning)),
        ],
      ),
    );
  }
}
