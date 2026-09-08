import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Shared text field, styled once with the RouteCraft brand
/// (`TravelAppColors.border`/`.textSecondary`) instead of each screen
/// repeating its own `InputDecoration`.
///
/// Built on [TextFormField] so it works both inside and outside a [Form] —
/// [validator] simply has no effect without an enclosing `Form`.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLines = 1,
  });

  final String labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: TravelAppColors.textSecondary),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: TravelAppColors.border),
        ),
      ),
    );
  }
}
