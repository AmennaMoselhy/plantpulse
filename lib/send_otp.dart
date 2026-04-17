import 'package:flutter/material.dart';
import 'otp_sheet.dart';

class SendOTP extends StatelessWidget {
  const SendOTP({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final email = args?['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: OtpSheet(email: email),
        ),
      ),
    );
  }
}