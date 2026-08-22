import 'package:flutter/material.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Dialog for change of Step Type
class ChangeStepTypeDialog extends StatelessWidget {
  const ChangeStepTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.changeStepTypeTitle),
      content: Text(l10n.changeStepTypeBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.proceedButton),
        ),
      ],
    );
  }
}

/// Dialog for change of Transport Type
class ChangeTransportTypeDialog extends StatelessWidget {
  const ChangeTransportTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.changeTransportTypeTitle),
      content: Text(l10n.changeTransportTypeBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.proceedButton),
        ),
      ],
    );
  }
}

