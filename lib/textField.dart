import 'package:flutter/material.dart';

class Textfield extends StatefulWidget {
  final String title;
  final String hint_text;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLines;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const Textfield({
    super.key,
    required this.title,
    required this.hint_text,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.controller,
    this.validator,
    this.enabled = true,
  });

  @override
  State<Textfield> createState() => _TextfieldState();
}

class _TextfieldState extends State<Textfield> {
  bool _passwordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _passwordHidden,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          textInputAction: TextInputAction.next,
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,
          // ✅ أسرع من onTapOutside
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F1F1F),
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: widget.hint_text,
            hintStyle: const TextStyle(
              color: Color(0xFF676767),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
            ),
            // ✅ error style
            errorStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              color: Color(0xFFD32F2F),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 0.6, color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 1.5, color: Color(0xFF399B25)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 1, color: Color(0xFFD32F2F)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 1.5, color: Color(0xFFD32F2F)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _passwordHidden ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined,
                color: const Color(0xFF676767),
                size: 24,
              ),
              onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
            )
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
          ),
        ),
      ],
    );
  }
}