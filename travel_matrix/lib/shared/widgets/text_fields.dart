import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomFormFieldType {
  text,
  number,
  date,
  email,
  document,
  password,
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

  /// Email field factory. Format validation (see [EmailValidator]) is the
  /// caller's responsibility, computed into [errorText] — the same pattern
  /// already used by the other factories in this widget.
  factory CustomFormField.email({
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
      type: CustomFormFieldType.email,
      errorText: errorText,
    );
  }

  /// CPF/CNPJ field factory. Format validation (see [CpfCnpjValidator]) is
  /// the caller's responsibility, computed into [errorText].
  factory CustomFormField.document({
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
      type: CustomFormFieldType.document,
      errorText: errorText,
    );
  }

  /// Password field factory (obscured text).
  factory CustomFormField.password({
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
      type: CustomFormFieldType.password,
      errorText: errorText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      enabled: enabled,

      /// Prevent keyboard on date field
      readOnly: type == CustomFormFieldType.date,

      obscureText: type == CustomFormFieldType.password,

      onChanged: onChanged,

      /// Used for date picker
      onTap: onTap,

      keyboardType: _keyboardType,

      inputFormatters: _inputFormatters,

      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? colorScheme.error : colorScheme.outlineVariant,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? colorScheme.error : colorScheme.primary,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }

  /// Keyboard type getter
  TextInputType get _keyboardType {
    switch (type) {
      case CustomFormFieldType.text:
      case CustomFormFieldType.document:
      case CustomFormFieldType.password:
        return TextInputType.text;

      case CustomFormFieldType.number:
        return TextInputType.number;

      case CustomFormFieldType.date:
        return TextInputType.datetime;

      case CustomFormFieldType.email:
        return TextInputType.emailAddress;
    }
  }

  /// Input formatters getter
  List<TextInputFormatter>? get _inputFormatters {
    switch (type) {
      case CustomFormFieldType.text:
      case CustomFormFieldType.date:
      case CustomFormFieldType.email:
      case CustomFormFieldType.document:
      case CustomFormFieldType.password:
        return null;

      case CustomFormFieldType.number:
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];
    }
  }
}