import 'package:flutter/material.dart';
import 'greenButton.dart';
import 'upGreenPlantPulse.dart';
import 'textField.dart';

class ChangePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          UpGreenPlantPulse(),
          SizedBox(height: size.height * 0.0296),
          Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF399B25)),
                ),
                SizedBox(height: size.height * 0.0296),
                const Textfield(
                  keyboardType: TextInputType.visiblePassword,
                  title: "New password",
                  hint_text: "Enter Your New password",
                  isPassword: true,
                ),
                SizedBox(height: size.height * 0.0197),
                const Textfield(
                  keyboardType: TextInputType.visiblePassword,
                  title: "Confirm New Password",
                  hint_text: "Re-enter Your New Password",
                  isPassword: true,
                ),
                SizedBox(height: size.height * 0.0591),
                GreenButton(
                  text: "Confirm Change",
                  onPress: () => showSuccessDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showSuccessDialog(BuildContext context) {
  final size = MediaQuery.of(context).size;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.053, vertical: size.height * 0.0296),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/right.png', cacheWidth: 100, width: size.width * 0.1, height: size.height * 0.0462),
              SizedBox(height: size.height * 0.0197),
              const Text("Password Changed Successfully!", textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF1F1F1F), fontSize: 14, fontWeight: FontWeight.w600)),
              SizedBox(height: size.height * 0.0099),
              const Text("You Can Now Use Your New Password To Log In", textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(height: size.height * 0.0394),
              SizedBox(
                width: size.width * 0.341,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399B25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Go Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}