import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'green_button.dart';
import 'down_text.dart';

class OTPHelper extends StatefulWidget {
  final String title;
  final String body;
  final bool isEmail;
  final String buttonText;
  final void Function(String email) onPress; // ✅ بيبعت الـ email

  const OTPHelper({
    super.key,
    required this.title,
    required this.body,
    required this.isEmail,
    required this.buttonText,
    required this.onPress,
  });

  @override
  State<OTPHelper> createState() => _OTPHelperState();
}

class _OTPHelperState extends State<OTPHelper> {
  final _emailController = TextEditingController();
  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  bool _isValidEmail = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _emailError = null;
        _isValidEmail = false;
      } else if (!_emailRegex.hasMatch(trimmed)) {
        _emailError = 'Enter a valid email';
        _isValidEmail = false;
      } else {
        _emailError = null;
        _isValidEmail = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(
        top: size.height * 0.1133,
        right: size.width * 0.064,
        left: size.width * 0.064,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/phoneframe.png',
              width: size.width * 0.448,
              height: size.height * 0.212,
              cacheWidth: (size.width * 0.448).toInt(),
            ),
          ),
          SizedBox(height: size.height * 0.0394),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF399B25),
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: size.height * 0.0099),
          Text(
            widget.body,
            style: const TextStyle(
              color: Color(0xFF6E6E6E),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: size.height * 0.0394),
          if (widget.isEmail) _buildEmailField() else _buildPinField(size),
          SizedBox(height: size.height * 0.0394),
          GreenButton(
            text: widget.buttonText,
            onPress: () => widget.onPress(_emailController.text.trim()),
            isDisabled: widget.isEmail && !_isValidEmail,
          ),
          if (!widget.isEmail) ...[
            SizedBox(height: size.height * 0.0591),
            DownText(
              label: "Didn't receive a code?",
              actionText: 'Resend code',
              onTap: () => Fluttertoast.showToast(
                msg: 'Code is being sent again...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: const Color(0xFF399B25),
                textColor: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: _onEmailChanged,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F1F1F),
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: 'Enter Your Email',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF676767),
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: _emailError,
            errorStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD32F2F),
              fontFamily: 'Poppins',
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _emailError != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFCCCCCC),
                width: 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _emailError != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF399B25),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinField(Size size) {
    return Center(
      child: MaterialPinField(
        length: 6,
        onCompleted: (pin) {
          widget.onPress(pin);
        },
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
    );
  }

}
