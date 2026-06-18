import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:PlantPulse/widgets/app_header.dart';
import 'package:PlantPulse/widgets/text_field.dart';
import 'package:PlantPulse/widgets/primary_button.dart';
import 'package:PlantPulse/widgets/social_login.dart.dart';
import 'package:PlantPulse/widgets/auth_link_text.dart';
import 'package:PlantPulse/state/user_state.dart';
import 'package:PlantPulse/widgets/register_widgets.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:PlantPulse/sheets/auth/register_otp_sheet.dart';

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
        children: const [
          UpGreenPlantPulse(),
          SizedBox(height: 20),
          _RegisterForm(),
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
  static const _emailJsServiceId = 'service_0lm6n0w';
  static const _emailJsTemplateId = 'template_m55wh4p';
  static const _emailJsPublicKey = 'Ig6lwDqT8MZwtw-_k';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _gender;
  bool _isLoading = false;

  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
  static const _signupUrl =
      'https://plant-pules-api.vercel.app/api/v1/auth/signup';

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

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _showError('Please select gender');
      return;
    }

    setState(() => _isLoading = true);

    final otp = (100000 + Random().nextInt(900000)).toString();

    try {
      await _sendOtpEmail(toEmail: _emailController.text.trim(), otp: otp);

      if (!mounted) return;
      setState(() => _isLoading = false);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => RegisterOtpSheet(
          email: _emailController.text.trim(),
          otp: otp,
          onVerified: _submitRegister,
          onResend: () async {
            final newOtp = (100000 + Random().nextInt(900000)).toString();
            await _sendOtpEmail(
              toEmail: _emailController.text.trim(),
              otp: newOtp,
            );
            return newOtp;
          },
        ),
      );
    } catch (e) {
      _showError('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtpEmail({
    required String toEmail,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _emailJsServiceId,
        'template_id': _emailJsTemplateId,
        'user_id': _emailJsPublicKey,
        'accessToken': 'sWNhvxhUfnyGQu1A8_1dY',
        'template_params': {'to_email': toEmail, 'otp_code': otp},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode}');
    }
  }

  Future<void> _submitRegister() async {
    if (mounted) setState(() => _isLoading = true);

    final fullName = _nameController.text.trim();
    final firstName = fullName.split(' ')[0];
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final dio = Dio();
      final response = await dio.post(
        _signupUrl,
        data: {
          'name': fullName,
          'email': email,
          'password': password,
          'confirmPassword': password,
          'gender': _gender!,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final token = response.data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await userState.saveToken(token);
      }

      await userState.saveUserData(
        email: email,
        password: password,
        fullName: fullName,
        gender: _gender!,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        'Login',
        (route) => false,
        arguments: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'fullName': fullName,
          'gender': _gender!,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed';
      _showError(msg);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
            AppTextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              title: 'Name',
              hintText: 'Enter Your Name',
              validator: _validateName,
            ),
            SizedBox(height: size.height * 0.005),
            AppTextField(
              title: 'Email',
              hintText: 'Enter Your Email',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: _validateEmail,
            ),
            SizedBox(height: size.height * 0.005),
            AppTextField(
              title: 'Password',
              controller: _passwordController,
              hintText: 'Enter Your Password',
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              validator: _validatePassword,
            ),
            SizedBox(height: size.height * 0.005),
            AppTextField(
              controller: _confirmPasswordController,
              title: 'Confirm Password',
              hintText: 'Enter Your Password',
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              validator: _validateConfirmPassword,
            ),
            SizedBox(height: size.height * 0.01),

            GenderSelector(
              selectedGender: _gender,
              onSelect: (gender) => setState(() => _gender = gender),
            ),
            SizedBox(height: size.height * 0.01),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF399B25)),
                  )
                : GreenButton(text: 'Register', onPress: _handleRegister),
            SizedBox(height: size.height * 0.02),
            LoginWithFaceBook(
              onEmailSelected: (email) {
                _emailController.text = email;
              },
            ),
            SizedBox(height: size.height * 0.015),
            DownText(
              label: 'Have an account?',
              actionText: 'Login',
              onTap: () => Navigator.of(context).pushNamed('Login'),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}
