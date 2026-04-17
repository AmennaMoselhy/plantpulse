import 'package:flutter/material.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  final bool isDisabled;

  const GreenButton({
    super.key,
    required this.text,
    required this.onPress,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.0591;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? const Color(0xFFBABABA)
              : const Color(0xFF399B25),
          disabledBackgroundColor: const Color(0xFFBABABA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        onPressed: isDisabled ? null : onPress,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
