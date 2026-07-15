import 'package:flutter/material.dart';

/// App-standard text field with a leading icon, label, error text, and optional
/// password obscuring toggle.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.label,
    this.hint,
    this.prefixIcon,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.controller,
    this.textInputAction,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final bool enabled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon:
            widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
