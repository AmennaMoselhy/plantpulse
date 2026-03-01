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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        child: _buildBody(),
      ),
    );
  }
  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
           UpGreenPlantPulse(),
          const SizedBox(height: 30),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildEmailField(),

          const SizedBox(height: 16),
          _buildPasswordField(),

          const SizedBox(height: 8),
          _buildForgotPassword(),

          const SizedBox(height: 32),
          _buildLoginButton(),

          const SizedBox(height: 32),

           LoginWithFaceBook(),

          const SizedBox(height: 100),
          _buildRegisterText(),
        ],
      ),
    );
  }
  Widget _buildEmailField() {
    return Textfield(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      title: "Email",
      hint_text: "Enter Your Email",
    );
  }
  Widget _buildPasswordField() {
    return Textfield(
      controller: _passwordController,
      keyboardType: TextInputType.visiblePassword,
      title: "Password",
      hint_text: "Enter Your Password",
      isPassword: true,
    );
  }
  Widget _buildForgotPassword() {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: _navigateToForgetPassword,
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
      ],
    );
  }
  Widget _buildLoginButton() {
    return GreenButton(
      text: 'Log in',
      onPress: _handleLogin,
    );
  }
  Widget _buildRegisterText() {
    return DownText(
      text1: "Don't have an account?",
      text2: "Register",
      fun: _navigateToRegister,
    );
  }
  void _navigateToForgetPassword() {
    Navigator.of(context).pushNamed('Forget_Password');
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('Register');
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      String name = "";
      Navigator.of(context).pushNamed('HomePage', arguments: name);
    }
  }
}