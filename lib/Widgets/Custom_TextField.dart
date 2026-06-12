import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  final String? prefixText;
  final Widget? suffixIcon;

  final VoidCallback? onTap;
  final bool readOnly;

  final bool isGlassStyle;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,

    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,

    this.prefixText,
    this.suffixIcon,

    this.onTap,
    this.readOnly = false,

    this.isGlassStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,

      readOnly: readOnly,
      onTap: onTap,

      style: TextStyle(
        color: isGlassStyle ? Colors.white : Colors.black,
      ),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: TextStyle(
          color: isGlassStyle ? Colors.white70 : Colors.black54,
        ),

        prefixIcon: icon != null ? Icon(icon) : null,

        prefixText: prefixText,
        suffixIcon: suffixIcon,

        filled: true,

        fillColor: isGlassStyle
            ? Colors.white.withOpacity(0.2)
            : Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}