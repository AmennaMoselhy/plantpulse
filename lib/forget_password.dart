import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'otp_helper_file.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _isLoading = false;

  static const _forgotUrl =
      'https://plant-pules-api.vercel.app/api/v1/password/forgot-password';

  Future<void> _handleSendOtp(String email) async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio();
      await dio.post(
        _forgotUrl,
        data: {'email': email},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed('Send_OTP', arguments: {'email': email});
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to send OTP';
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: OTPHelper(
            title: 'Forgot Password?',
            body:
                'Did you forget your password? Click here to recover it easily',
            isEmail: true,
            buttonText: _isLoading ? 'Sending...' : 'Send OTP',
            onPress: _handleSendOtp,
          ),
        ),
      ),
    );
  }
}
