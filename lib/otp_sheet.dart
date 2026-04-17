import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'reset_password_sheet.dart';
import 'green_button.dart';
import 'package:dio/dio.dart';
import 'user_state.dart';

class OtpSheet extends StatefulWidget {
  final String email;
  final bool isFromProfile;
  final String? newPassword;

  const OtpSheet({
    super.key,
    required this.email,
    this.isFromProfile = false,
    this.newPassword,
  });

  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  static const int _otpLength = 6;
  static const int _timerDuration = 20;

  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());

  int _secondsLeft = _timerDuration;
  Timer? _timer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _timerDuration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _onResendTap() async {
    if (_secondsLeft > 0) return;
    try {
      final dio = Dio();
      await dio.post(
        'https://plant-pules-api.vercel.app/api/v1/password/forgot-password',
        data: {'email': widget.email},
      );
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Code sent again!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF399B25),
        textColor: Colors.white,
        fontSize: 14,
      );
      _startTimer();
    } catch (_) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Failed to resend code',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 14,
      );
    }
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {
      _isComplete = _controllers.every((c) => c.text.isNotEmpty);
    });
  }

  Future<void> _handleVerify() async {
    if (!_isComplete) return;
    final otp = _controllers.map((c) => c.text).join();

    try {
      final dio = Dio();

      await dio.post(
        'https://plant-pules-api.vercel.app/api/v1/password/verify-reset-code',
        data: {'email': widget.email, 'otp': otp},
      );

      if (widget.newPassword != null) {
        await dio.post(
          'https://plant-pules-api.vercel.app/api/v1/password/reset-password',
          data: {
            'email': widget.email,
            'newPassword': widget.newPassword,
          },
        );

        await userState.updatePassword(widget.newPassword!);

        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == 'HomePage');

        Fluttertoast.showToast(
          msg: 'Password changed successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: const Color(0xFF399B25),
          textColor: Colors.white,
          fontSize: 14,
        );
        return;
      }

      if (!mounted) return;
      if (widget.isFromProfile) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const ResetPasswordSheet(),
        );
      } else {
        Navigator.of(context).pushNamed(
          'Change_Password',
          arguments: {'email': widget.email},
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Invalid code';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  String get _timerText => '00:${_secondsLeft.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boxSize = size.width * 0.13;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We've sent a code to ${widget.email}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF717171),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: boxSize,
                    height: boxSize,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF399B25),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF399B25),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              GreenButton(
                text: 'Verify',
                onPress: _handleVerify,
                isDisabled: !_isComplete,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _onResendTap,
                    child: Text(
                      'Send code again',
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondsLeft == 0
                            ? const Color(0xFF399B25)
                            : const Color(0xFF717171),
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        decorationColor: _secondsLeft == 0
                            ? const Color(0xFF399B25)
                            : const Color(0xFF717171),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _timerText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF717171),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}