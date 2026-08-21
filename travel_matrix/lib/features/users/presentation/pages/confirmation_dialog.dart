import 'package:flutter/material.dart';

/// Shows a generic confirmation dialog before a destructive/irreversible
/// action. Returns true if the user confirmed, false/null otherwise.
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}
