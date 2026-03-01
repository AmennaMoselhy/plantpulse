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
  bool password_hidden = true;

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
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          enabled: widget.enabled,
          obscureText: widget.isPassword ? password_hidden : false,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          textInputAction: TextInputAction.next,
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: widget.hint_text,
            hintStyle: const TextStyle(
              color: Color(0xFF676767),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                width: 0.6,
                color: Color(0xFFCCCCCC),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                width: 1.5,
                color: Color(0xFF399B25),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                password_hidden
                    ? Icons.visibility_off_outlined
                    : Icons.remove_red_eye_outlined,
                color: const Color(0xFF676767),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  password_hidden = !password_hidden;
                });
              },
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