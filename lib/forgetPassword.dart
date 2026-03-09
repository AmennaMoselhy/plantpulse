import 'package:flutter/material.dart';
import 'otpHelperFile.dart';

class ForgetPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

          child: OTPHelper(
            title: "Forgot Password?",
            body:
                "Did you forget your password? Click here to recover it easily",
            isEmail: true,
            button_text: "Send OTP",
            onPress: () {
              Navigator.of(context).pushNamed('Send_OTP');
            },
          ),
        ),
      ),
    );
  }
}
