import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomFormFieldType {
  text,
  number,
  date,
}

class CustomFormField extends StatelessWidget {
  final String label;

  /// String for error
  final String? errorText;

  /// Boolean to enable the text field
  final bool enabled;

  /// Text editor controller
  final TextEditingController controller;

  /// On changed callback
  final ValueChanged<String> onChanged;

  /// Field type
  final CustomFormFieldType type;

  /// Callback for date picker
  final VoidCallback? onTap;

  /// Private constructor
  const CustomFormField._({
    super.key,
    required this.label,
    required this.enabled,
    required this.controller,
    required this.onChanged,
    required this.type,
    this.errorText,
    this.onTap,
  });

  /// Text field factory
  factory CustomFormField.text({
    Key? key,
    required String label,
    required bool enabled,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return CustomFormField._(
      key: key,
      label: label,
      enabled: enabled,
      controller: controller,
      onChanged: onChanged,
      type: CustomFormFieldType.text,
      errorText: errorText,
    );
  }

  /// Number field factory
  factory CustomFormField.number({
    Key? key,
    required String label,
    required bool enabled,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return CustomFormField._(
      key: key,
      label: label,
      enabled: enabled,
      controller: controller,
      onChanged: onChanged,
      type: CustomFormFieldType.number,
      errorText: errorText,
    );
  }

  /// Date field factory
  factory CustomFormField.date({
    Key? key,
    required String label,
    required bool enabled,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return CustomFormField._(
      key: key,
      label: label,
      enabled: enabled,
      controller: controller,
      onChanged: (_) {},
      type: CustomFormFieldType.date,
      errorText: errorText,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,

      /// Prevent keyboard on date field
      readOnly: type == CustomFormFieldType.date,

      onChanged: onChanged,

      /// Used for date picker
      onTap: onTap,

      keyboardType: _keyboardType,

      inputFormatters: _inputFormatters,

      /// Bordas (padrão/foco/erro) vêm do `inputDecorationTheme` do app —
      /// o TextField já seleciona a borda de erro sozinho quando `errorText`
      /// não é nulo, sem precisar duplicar essa lógica aqui.
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
      ),
    );
  }

  /// Keyboard type getter
  TextInputType get _keyboardType {
    switch (type) {
      case CustomFormFieldType.text:
        return TextInputType.text;

      case CustomFormFieldType.number:
        return TextInputType.number;

      case CustomFormFieldType.date:
        return TextInputType.datetime;
    }
  }

  /// Input formatters getter
  List<TextInputFormatter>? get _inputFormatters {
    switch (type) {
      case CustomFormFieldType.text:
        return null;

      case CustomFormFieldType.number:
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];

      case CustomFormFieldType.date:
        return null;
    }
  }
}