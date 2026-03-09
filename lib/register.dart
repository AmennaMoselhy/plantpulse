import 'package:flutter/material.dart';
import 'upGreenPlantPulse.dart';
import 'textField.dart';
import 'greenButton.dart';
import 'logWithFacebook.dart';
import 'downText.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Textfield(
              controller: _nameController,
              keyboardType: TextInputType.name,
              title: "Name",
              hint_text: "Enter Your Name",
              validator: (value) {
                if (value == null || value.isEmpty) return 'Name is required';
                if (value.length < 5) return 'Name must be at least 5 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Textfield(
              title: "Email",
              hint_text: "Enter Your Email",
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 12),
            Textfield(
              title: "Password",
              controller: _passwordController,
              hint_text: "Enter Your Password",
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 12),
            Textfield(
              controller: _confirmPasswordController,
              title: "Confirm Password",
              hint_text: "Enter Your Password",
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 16),
            GreenButton(
              text: 'Register',
              onPress: () {
                if (_formKey.currentState!.validate()) {
                  String firstName = _nameController.text.split(' ')[0];
                  String fullName = _nameController.text;
                  Navigator.of(context).pushNamed(
                    'HomePage',
                    arguments: {'firstName': firstName, 'fullName': fullName},
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            LoginWithFaceBook(),
            const SizedBox(height: 12),
            DownText(
              text1: "Have an account?",
              text2: "Login",
              fun: () => Navigator.of(context).pushNamed('Login'),
            ),
          ],
        ),
      ),
    );
  }
}