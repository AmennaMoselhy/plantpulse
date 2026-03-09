import 'package:flutter/material.dart';
import 'upGreenPlantPulse.dart';
import 'textField.dart';
import 'greenButton.dart';
import 'downText.dart';
import 'logWithFacebook.dart';
import 'user_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✅ Regex ثابت — متتعملش كل مرة
  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      userState.saveUserData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        'HomePage',
        arguments: {
          'firstName': '',
          'fullName': '',
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          children: [
            UpGreenPlantPulse(),
            SizedBox(height: size.height * 0.0355),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Textfield(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    title: "Email",
                    hint_text: "Enter Your Email",
                    validator: _validateEmail,
                  ),
                  SizedBox(height: size.height * 0.019),
                  Textfield(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    title: "Password",
                    hint_text: "Enter Your Password",
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: size.height * 0.0099),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('Forget_Password'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF399B25),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.0394),
                  GreenButton(text: 'Log in', onPress: _handleLogin),
                  SizedBox(height: size.height * 0.0394),
                  LoginWithFaceBook(
                    onEmailSelected: (email) {
                      _emailController.text = email;
                    },
                  ),
                  SizedBox(height: size.height * 0.1),
                  DownText(
                    text1: "Don't have an account?",
                    text2: "Register",
                    fun: () => Navigator.of(context).pushNamed('Register'),
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
