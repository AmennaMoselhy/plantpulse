import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:PlantPulse/widgets/primary_button.dart';

class RegisterOtpSheet extends StatefulWidget {
  final String email;
  final String otp;
  final Future<String> Function() onResend;
  final VoidCallback onVerified;

  const RegisterOtpSheet({
    super.key,
    required this.email,
    required this.otp,
    required this.onResend,
    required this.onVerified,
  });

  @override
  State<RegisterOtpSheet> createState() => _RegisterOtpSheetState();
}

class _RegisterOtpSheetState extends State<RegisterOtpSheet> {
  static const int _otpLength = 6;
  static const int _timerDuration = 60;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _timerDuration;
  Timer? _timer;
  bool _isComplete = false;
  String? _otpError;
  String _currentOtp;

  _RegisterOtpSheetState() : _currentOtp = '';

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otp;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _timerDuration);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {
      _isComplete = _controllers.every((c) => c.text.isNotEmpty);
      _otpError = null;
    });
  }

  void _handleVerify() {
    if (!_isComplete) return;
    final entered = _controllers.map((c) => c.text).join();
    if (entered == _currentOtp) {
      Navigator.pop(context);
      widget.onVerified();
    } else {
      setState(() => _otpError = 'Invalid code. Please try again.');
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
                'Verify your email',
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              if (_otpError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _otpError!,
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
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
                    onTap: _secondsLeft == 0
                        ? () async {
                      final newOtp = await widget.onResend();
                      setState(() {
                        _currentOtp = newOtp;
                        for (final c in _controllers) c.clear();
                        _isComplete = false;
                        _otpError = null;
                      });
                      _startTimer();
                    }
                        : null,
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
