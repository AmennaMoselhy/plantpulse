import 'package:flutter/material.dart';

class LoginWithFaceBook extends StatelessWidget {
  final void Function(String email)? onEmailSelected;

  const LoginWithFaceBook({super.key, this.onEmailSelected});

  // ✅ إيميلات وهمية لحد ما الباك اند يجهز
  static const _mockEmails = [
    'user@gmail.com',
    'user@outlook.com',
    'user@yahoo.com',
    'user@hotmail.com',
  ];

  Future<void> _showEmailPicker(BuildContext context, String provider) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Continue with $provider',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Color(0xFF1F1F1F)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _mockEmails.map((email) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined, color: Color(0xFF399B25), size: 20),
            title: Text(email, style: const TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
            onTap: () => Navigator.pop(context, email),
          )).toList(),
        ),
      ),
    );

    if (selected != null) {
      onEmailSelected?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
          child: Column(
            children: [
              const Text(
                "Or login with",
                style: TextStyle(fontSize: 10, color: Color(0xFF399B25), fontWeight: FontWeight.w400, fontFamily: 'Poppins'),
              ),
              SizedBox(height: size.height * 0.0296),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showEmailPicker(context, 'Facebook'),
                    child: Image.asset('assets/facebook_logo.png', height: size.height * 0.0296, width: size.width * 0.064),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showEmailPicker(context, 'Google'),
                    child: Image.asset('assets/google_logo.png', height: size.height * 0.0296, width: size.width * 0.064),
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