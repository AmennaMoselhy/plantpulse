import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'up_green_plant_pulse.dart';
import 'text_field.dart';
import 'green_button.dart';
import 'log_with_facebook.dart';
import 'down_text.dart';
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

    setState(() => _isLoading = true);

    final fullName = _nameController.text.trim();
    final firstName = fullName.split(' ')[0];
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_gender == null) {
      _showError('Please select gender');
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        _signupUrl,
        data: {
          'name': fullName,
          'email': email,
          'password': password,
          'confirmPassword': password,
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

      userState.saveUserData(
        email: email,
        password: password,
        fullName: fullName,
        gender: _gender!,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        'HomePage',
        (route) => false,
        arguments: {
          'firstName': firstName,
          'fullName': fullName,
          'email': email,
          'gender': _gender,
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
            Textfield(
              controller: _nameController,
              keyboardType: TextInputType.name,
              title: 'Name',
              hintText: 'Enter Your Name',
              validator: _validateName,
            ),
            SizedBox(height: size.height * 0.005),
            Textfield(
              title: 'Email',
              hintText: 'Enter Your Email',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: _validateEmail,
            ),
            SizedBox(height: size.height * 0.005),
            Textfield(
              title: 'Password',
              controller: _passwordController,
              hintText: 'Enter Your Password',
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              validator: _validatePassword,
            ),
            SizedBox(height: size.height * 0.005),
            Textfield(
              controller: _confirmPasswordController,
              title: 'Confirm Password',
              hintText: 'Enter Your Password',
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              validator: _validateConfirmPassword,
            ),
            SizedBox(height: size.height * 0.01),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _gender = 'male';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _gender == 'male'
                            ? const Color(0xFF399B25).withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _gender == 'male'
                              ? const Color(0xFF399B25)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.male,
                            size: 28,
                            color: _gender == 'male'
                                ? const Color(0xFF399B25)
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          const Text('Male'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _gender = 'female';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _gender == 'female'
                            ? const Color(0xFF399B25).withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _gender == 'female'
                              ? const Color(0xFF399B25)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.female,
                            size: 28,
                            color: _gender == 'female'
                                ? const Color(0xFF399B25)
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          const Text('Female'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
