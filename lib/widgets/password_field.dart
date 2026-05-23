import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? errorText;

  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F1F1F),
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF676767),
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: widget.errorText,
            errorStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD32F2F),
              fontFamily: 'Poppins',
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _hidden
                    ? Icons.visibility_off_outlined
                    : Icons.remove_red_eye_outlined,
                color: const Color(0xFF676767),
                size: 22,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.errorText != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFCCCCCC),
                width: 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.errorText != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF399B25),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}