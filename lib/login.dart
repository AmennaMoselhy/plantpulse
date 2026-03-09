import 'package:flutter/material.dart';
import 'upGreenPlantPulse.dart';
import 'textField.dart';
import 'greenButton.dart';
import 'downText.dart';
import 'logWithFacebook.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          physics: const BouncingScrollPhysics(),
          children: [
            UpGreenPlantPulse(),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Textfield(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    title: "Email",
                    hint_text: "Enter Your Email",
                  ),
                  const SizedBox(height: 16),
                  Textfield(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    title: "Password",
                    hint_text: "Enter Your Password",
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('Forget_Password'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(fontWeight: FontWeight.w400, fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF399B25)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GreenButton(
                    text: 'Log in',
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pushNamed(
                          'HomePage',
                          arguments: {
                            'firstName': _emailController.text.split('@')[0],
                            'fullName': _emailController.text.split('@')[0],
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  LoginWithFaceBook(),
                  const SizedBox(height: 100),
                  DownText(
                    text1: "Don't have an account?",
                    text2: "Register",
                    fun: () => Navigator.of(context).pushNamed('Register'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}