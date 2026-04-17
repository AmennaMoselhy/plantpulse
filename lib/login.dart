import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'up_green_plant_pulse.dart';
import 'text_field.dart';
import 'green_button.dart';
import 'down_text.dart';
import 'log_with_facebook.dart';
import 'user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recent_scan.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
  static const _signinUrl =
      'https://plant-pules-api.vercel.app/api/v1/auth/signin';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await userState.loadPersistedData();

      final savedEmail = userState.email;
      final savedPassword = userState.password;

      if (savedEmail == email &&
          savedPassword == password &&
          savedPassword.isNotEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          'HomePage',
          (route) => false,
          arguments: {
            'firstName': userState.fullName.isNotEmpty
                ? userState.fullName.split(' ')[0]
                : '',
            'fullName': userState.fullName,
            'email': email,
            'password': password,
          },
        );
        return;
      }

      final dio = Dio();
      final response = await dio.post(
        _signinUrl,
        data: {'email': email, 'password': password},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final token = response.data['token'] as String?;

      if (token == null || token.isEmpty) {
        _showError('Login failed. Please try again.');
        return;
      }

      await userState.saveToken(token);

      try {
        final profileRes = await dio.get(
          'https://plant-pules-api.vercel.app/api/v1/users/profile',
          options: Options(headers: {'token': token}),
        );
        final name = profileRes.data['data']['name'] as String? ?? '';
        final prefs = await SharedPreferences.getInstance();
        final savedGender = prefs.getString('savedGender') ?? 'male';
        userState.saveUserData(
          email: email,
          password: password,
          fullName: name,
          gender: savedGender,
        );
        await loadScansFromApi(token);
      } catch (_) {
        userState.saveUserData(email: email, password: password, fullName: '');
      }
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        'HomePage',
        (route) => false,
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName,
          'email': email,
          'password': password,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Invalid email or password';
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
            const UpGreenPlantPulse(),
            SizedBox(height: size.height * 0.0355),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Textfield(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    title: 'Email',
                    hintText: 'Enter Your Email',
                    validator: _validateEmail,
                  ),
                  SizedBox(height: size.height * 0.019),
                  Textfield(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    title: 'Password',
                    hintText: 'Enter Your Password',
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
                        'Forgot Password?',
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
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF399B25),
                          ),
                        )
                      : GreenButton(text: 'Log in', onPress: _handleLogin),
                  SizedBox(height: size.height * 0.0394),
                  LoginWithFaceBook(
                    onEmailSelected: (email) {
                      _emailController.text = email;
                    },
                  ),
                  SizedBox(height: size.height * 0.1),
                  DownText(
                    label: "Don't have an account?",
                    actionText: 'Register',
                    onTap: () => Navigator.of(context).pushNamed('Register'),
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
