import 'package:flutter/material.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

Future<String?> showDeactivateUserDialog(
  BuildContext context,
  String userName,
) {
  return showDialog<String>(
    context: context,
    builder: (context) => _DeactivateUserDialog(userName: userName),
  );
}

class _DeactivateUserDialog extends StatefulWidget {
  final String userName;

  const _DeactivateUserDialog({required this.userName});

  @override
  State<_DeactivateUserDialog> createState() => _DeactivateUserDialogState();
}

class _DeactivateUserDialogState extends State<_DeactivateUserDialog> {
  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final otherReason = l10n.otherOptionLabel;
    final reasons = [
      l10n.deactivateReasonClientRequest,
      l10n.deactivateReasonNonPayment,
      l10n.deactivateReasonTermsViolation,
      l10n.deactivateReasonDuplicateAccount,
      otherReason,
    ];

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.block, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(l10n.deactivateUserDialogTitle),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deactivateReasonPrompt(widget.userName),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: reasons.map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
            if (_selectedReason == otherReason)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 32.0),
                child: TextField(
                  controller: _otherReasonController,
                  decoration: InputDecoration(
                    labelText: l10n.specifyReasonFieldLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancelActionButton),
        ),
        ElevatedButton(
          onPressed:
              _selectedReason == null ||
                  (_selectedReason == otherReason &&
                      _otherReasonController.text.trim().isEmpty)
              ? null
              : () {
                  final reason = _selectedReason == otherReason
                      ? _otherReasonController.text.trim()
                      : _selectedReason!;
                  Navigator.of(context).pop(reason);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(l10n.deactivateButtonCaps),
        ),
      ],
    );
  }
}
