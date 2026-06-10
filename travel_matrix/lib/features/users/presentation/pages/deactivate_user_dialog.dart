import 'package:flutter/material.dart';

Future<String?> showDeactivateUserDialog(BuildContext context, String userName) {
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

  final List<String> _reasons = [
    'Solicitação do cliente',
    'Inadimplência',
    'Violação de termos de uso',
    'Conta duplicada',
    'Outro'
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.block, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          const Text('Desativar Usuário'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Por que você está desativando '),
                  TextSpan(
                    text: widget.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
            if (_selectedReason == 'Outro')
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 32.0),
                child: TextField(
                  controller: _otherReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Especifique o motivo',
                    border: OutlineInputBorder(),
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
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _selectedReason == null || (_selectedReason == 'Outro' && _otherReasonController.text.trim().isEmpty)
              ? null
              : () {
                  final reason = _selectedReason == 'Outro'
                      ? _otherReasonController.text.trim()
                      : _selectedReason!;
                  Navigator.of(context).pop(reason);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('DESATIVAR'),
        ),
      ],
    );
  }
}
