import 'package:flutter/material.dart';
import 'upGreenPlantPulse.dart';
import 'textField.dart';
import 'greenButton.dart';
import 'logWithFacebook.dart';
import 'downText.dart';
import 'user_state.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: EdgeInsets.zero,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        children: [
          UpGreenPlantPulse(),
          const SizedBox(height: 20),
          const _RegisterForm(),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 5) return 'Name must be at least 5 characters';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _handleRegister() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final firstName = _nameController.text.trim().split(' ')[0];
      final fullName = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // ✅ حفظ البيانات في userState
      userState.saveUserData(email: email, password: password);

      Navigator.of(context).pushReplacementNamed(
        'HomePage',
        arguments: {
          'firstName': firstName,
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Textfield(
              controller: _nameController,
              keyboardType: TextInputType.name,
              title: "Name",
              hint_text: "Enter Your Name",
              validator: _validateName,
            ),
            SizedBox(height: size.height * 0.015),
            Textfield(
              title: "Email",
              hint_text: "Enter Your Email",
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: _validateEmail,
            ),
            SizedBox(height: size.height * 0.015),
            Textfield(
              title: "Password",
              controller: _passwordController,
              hint_text: "Enter Your Password",
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              validator: _validatePassword,
            ),
            SizedBox(height: size.height * 0.015),
            Textfield(
              controller: _confirmPasswordController,
              title: "Confirm Password",
              hint_text: "Enter Your Password",
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              validator: _validateConfirmPassword,
            ),
            SizedBox(height: size.height * 0.02),
            GreenButton(text: 'Register', onPress: _handleRegister),
            SizedBox(height: size.height * 0.02),
            // ✅ لما يختار إيميل بيتحط في خانة الإيميل
            LoginWithFaceBook(
              onEmailSelected: (email) {
                _emailController.text = email;
              },
            ),
            SizedBox(height: size.height * 0.015),
            DownText(
              text1: "Have an account?",
              text2: "Login",
              fun: () => Navigator.of(context).pushNamed('Login'),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}
