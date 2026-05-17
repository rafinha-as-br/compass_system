import 'package:flutter/material.dart';

/// Dialog for change of Step Type
class ChangeStepTypeDialog extends StatelessWidget {
  const ChangeStepTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Step Type?'),
      content: const Text('Changing the step type will result in the loss of specific data entered for the current step. Do you wish to proceed?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Proceed'),
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
    return const Placeholder();
  }
}

