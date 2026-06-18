import 'package:flutter/material.dart';

class DownText extends StatelessWidget {
  final String label;
  final String actionText;
  final VoidCallback onTap;

  const DownText({
    super.key,
    required this.label,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            color: Color(0xFF6E6E6E),
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF399B25),
              fontFamily: 'Poppins',
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF399B25),
            ),
          ),
        ),
      ],
    );
  }
}
