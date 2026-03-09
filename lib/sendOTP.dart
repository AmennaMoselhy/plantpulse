import 'package:flutter/material.dart';
import 'otpHelperFile.dart';

class SendOTP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          physics: const BouncingScrollPhysics(),

          children: [
            OTPHelper(
              title: "OTP Verification code",
              body:
                  "Enter the OTP code we’ve sent to your email to verify your identity",
              isEmail: false,
              button_text: "Verify",
              onPress: () {
                Navigator.of(context).pushNamed('Change_Password');
              },
            ),
          ],
        ),
      ),
    );
  }
}
