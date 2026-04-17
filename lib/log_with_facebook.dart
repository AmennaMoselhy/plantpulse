import 'package:flutter/material.dart';

class LoginWithFaceBook extends StatelessWidget {
  final void Function(String email)? onEmailSelected;

  const LoginWithFaceBook({super.key, this.onEmailSelected});

  void _showEmailPicker(BuildContext context, String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'Coming Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Color(0xFF1F1F1F),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF399B25), fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.height * 0.0296;
    final logoWidth = size.width * 0.064;

    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
          child: Column(
            children: [
              const Text(
                'Or login with',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF399B25),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.0296),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showEmailPicker(context, 'Facebook'),
                    child: Image.asset(
                      'assets/facebook_logo.png',
                      height: logoSize,
                      width: logoWidth,
                      cacheHeight: logoSize.toInt(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showEmailPicker(context, 'Google'),
                    child: Image.asset(
                      'assets/google_logo.png',
                      height: logoSize,
                      width: logoWidth,
                      cacheHeight: logoSize.toInt(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
      ],
    );
  }
}
