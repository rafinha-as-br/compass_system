import 'package:flutter/material.dart';

/// Shows a confirmation dialog before deleting a user.
/// Returns true if the user confirmed the deletion.
Future<bool?> showDeleteUserDialog(BuildContext context, String userName) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.error),
            const SizedBox(width: 8),
            const Text('Confirm Deletion'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                  text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('DELETE'),
          ),
        ],
      );
    },
  );
}
