import 'package:flutter/material.dart';
import 'textField.dart';
import 'greenButton.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'downText.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTPHelper extends StatelessWidget {
  final String title;
  final String body;
  final bool isEmail;
  final String button_text;
  final VoidCallback onPress;

  OTPHelper({
    required this.title,
    required this.body,
    required this.isEmail,
    required this.button_text,
    required this.onPress,
  });

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        top: size.height * 0.1133,
        bottom: size.height * 0.3041,
        right: size.width * 0.064,
        left: size.width * 0.064,
      ),
      height: size.height * 0.683,
      width: size.width * 0.872,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/phoneframe.png',
                  width: size.width * 0.448,
                  height: size.height * 0.212,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.0394),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF399B25),
            ),
          ),
          SizedBox(height: size.height * 0.0099),
          Text(
            body,
            style: const TextStyle(
              color: const Color(0xFF6E6E6E),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          SizedBox(height: size.height * 0.0394),
          isEmail
              ? const Textfield(
                  keyboardType: TextInputType.emailAddress,
                  title: "Email",
                  hint_text: "Enter Your Email",
                )
              : Center(
                  child: MaterialPinField(
                    length: 5,
                    theme: MaterialPinTheme(
                      shape: MaterialPinShape.outlined,
                      focusedFillColor: const Color(0xFFF7F7F7),
                      fillColor: const Color(0xFFF7F7F7),
                      borderColor: const Color(0xFF868686),
                      borderRadius: BorderRadius.circular(4),
                      focusedBorderColor: const Color(0xFF399B25),
                      cursorColor: const Color(0xFF399B25),

                      cellSize: Size(size.width * 0.133, size.height * 0.0493),
                    ),
                  ),
                ),
          SizedBox(height: size.height * 0.0394),
          GreenButton(text: button_text, onPress: onPress),
          if (!isEmail) SizedBox(height: size.height * 0.0591),

          if (!isEmail)
            DownText(
              text1: "Didn’t received code?",
              text2: "Resend code",
              fun: () {
                Fluttertoast.showToast(
                  msg: "Code is being sent again...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: const Color(0xFF399B25),
                  textColor: Colors.white,
                  fontSize: 14,
                );
              },
            ),
        ],
      ),
    );
  }
}
