import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import 'package:PlantPulse/state/user_state.dart';

class EditEmailSheet extends StatefulWidget {
  final void Function(String newEmail) onSave;

  const EditEmailSheet({super.key, required this.onSave});

  @override
  State<EditEmailSheet> createState() => _EditEmailSheetState();
}

enum _Step { enterEmail, enterOtp, enterPassword }

class _EditEmailSheetState extends State<EditEmailSheet> {
  _Step _step = _Step.enterEmail;
  bool _isLoading = false;

  final _newEmailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _otpError;
  String? _passwordError;

  String _generatedOtp = '';
  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  // EmailJS credentials (نفس المستخدمة في register)
  static const _emailJsServiceId = 'service_0lm6n0w';
  static const _emailJsTemplateId = 'template_m55wh4p';
  static const _emailJsPublicKey = 'Ig6lwDqT8MZwtw-_k';
  static const _emailJsPrivateKey = 'sWNhvxhUfnyGQu1A8_1dY';

  @override
  void dispose() {
    _newEmailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generateOtp() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  Future<bool> _sendOtpEmail(String toEmail, String otp) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': _emailJsServiceId,
          'template_id': _emailJsTemplateId,
          'user_id': _emailJsPublicKey,
          'accessToken': _emailJsPrivateKey,
          'template_params': {
            'to_email': toEmail,
            'otp_code': otp,
          },
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// يتحقق هل الإيميل مستخدم قبل كده عن طريق forgetPassword endpoint
  /// لو رجع نجاح/200 يبقى الإيميل موجود (مستخدم) -> نوقف
  /// لو رجع 404/فشل يبقى الإيميل غير موجود -> متاح للاستخدام
  Future<bool> _isEmailAlreadyUsed(String email) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://plant-pules-api.vercel.app/api/v1/auth/forgetPassword',
        data: {'email': email},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      // لو نجح الطلب، يبقى الإيميل ده موجود فعلاً في النظام
      return response.statusCode == 200;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // 404 / 400 غالباً معناها الإيميل غير موجود = متاح
      if (code == 404 || code == 400) return false;
      // أي error تاني (شبكة، سيرفر) نتعامل معاه كـ "متاح" بدل ما نوقف اليوزر بدون سبب واضح
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleEmailNext() async {
    final email = _newEmailController.text.trim();
    setState(() => _emailError = null);

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email');
      return;
    }
    if (email.toLowerCase() == userState.email.toLowerCase()) {
      setState(() => _emailError = 'This is already your current email');
      return;
    }

    setState(() => _isLoading = true);

    final used = await _isEmailAlreadyUsed(email);
    if (used) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'This email is already registered with another account',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 13,
      );
      return;
    }

    _generatedOtp = _generateOtp();
    final sent = await _sendOtpEmail(email, _generatedOtp);

    setState(() => _isLoading = false);

    if (!sent) {
      Fluttertoast.showToast(
        msg: 'Failed to send verification code. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 13,
      );
      return;
    }

    if (!mounted) return;
    setState(() => _step = _Step.enterOtp);
  }

  Future<void> _handleResendOtp() async {
    final email = _newEmailController.text.trim();
    setState(() => _isLoading = true);
    _generatedOtp = _generateOtp();
    final sent = await _sendOtpEmail(email, _generatedOtp);
    setState(() => _isLoading = false);

    if (!mounted) return;
    Fluttertoast.showToast(
      msg: sent ? 'Verification code resent' : 'Failed to resend code',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: sent ? const Color(0xFF399B25) : const Color(0xFFD32F2F),
      textColor: Colors.white,
      fontSize: 13,
    );
  }

  void _handleOtpNext() {
    final otp = _otpController.text.trim();
    setState(() => _otpError = null);

    if (otp.isEmpty) {
      setState(() => _otpError = 'Verification code is required');
      return;
    }
    if (otp != _generatedOtp) {
      setState(() => _otpError = 'Incorrect verification code');
      return;
    }

    setState(() => _step = _Step.enterPassword);
  }

  Future<void> _handlePasswordConfirm() async {
    final password = _passwordController.text;
    setState(() => _passwordError = null);

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      // نتأكد من الباسورد عن طريق تجربة signin بالإيميل القديم
      final signInRes = await dio.post(
        'https://plant-pules-api.vercel.app/api/v1/auth/signin',
        data: {'email': userState.email, 'password': password},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (signInRes.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _passwordError = 'Incorrect password';
        });
        return;
      }

      final newEmail = _newEmailController.text.trim();

      // حدثي الإيميل على الـ API
      await dio.put(
        'https://plant-pules-api.vercel.app/api/v1/users/profile/email',
        data: {'email': newEmail},
        options: Options(
          headers: {'token': userState.token},
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      await userState.updateEmail(newEmail);
      widget.onSave(newEmail);

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Email updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF399B25),
        textColor: Colors.white,
        fontSize: 14,
      );
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      final code = e.response?.statusCode;
      if (code == 401 || code == 400) {
        setState(() => _passwordError = 'Incorrect password');
      } else {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: const Color(0xFFD32F2F),
          textColor: Colors.white,
          fontSize: 13,
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 13,
      );
    }
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              _buildStepContent(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _Step.enterEmail:
        return _buildEmailStep();
      case _Step.enterOtp:
        return _buildOtpStep();
      case _Step.enterPassword:
        return _buildPasswordStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Change Email',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
        const SizedBox(height: 4),
        const Text('Enter your new email address. We will send a verification code to confirm it.',
            style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Color(0xFF676767))),
        const SizedBox(height: 20),
        _buildField(
          label: 'New Email',
          controller: _newEmailController,
          hasError: _emailError != null,
          errorText: _emailError ?? '',
          keyboardType: TextInputType.emailAddress,
          onClearError: () => setState(() => _emailError = null),
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          label: 'Next',
          onPressed: () async {
            await _vibrate();
            _handleEmailNext();
          },
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verify Your Email',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
        const SizedBox(height: 4),
        Text('Enter the 6-digit code sent to ${_newEmailController.text.trim()}',
            style: const TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Color(0xFF676767))),
        const SizedBox(height: 20),
        _buildField(
          label: 'Verification Code',
          controller: _otpController,
          hasError: _otpError != null,
          errorText: _otpError ?? '',
          keyboardType: TextInputType.number,
          onClearError: () => setState(() => _otpError = null),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _handleResendOtp,
            child: const Text('Resend code',
                style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Color(0xFF399B25))),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'Next',
          onPressed: () async {
            await _vibrate();
            _handleOtpNext();
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Your Password',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
        const SizedBox(height: 4),
        const Text('Enter your current password to confirm this change.',
            style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Color(0xFF676767))),
        const SizedBox(height: 20),
        _buildField(
          label: 'Password',
          controller: _passwordController,
          hasError: _passwordError != null,
          errorText: _passwordError ?? '',
          isPassword: true,
          onClearError: () => setState(() => _passwordError = null),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Please use "Forgot Password" from the login screen first',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                backgroundColor: const Color(0xFF399B25),
                textColor: Colors.white,
                fontSize: 13,
              );
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: const Text('Forgot password?',
                style: TextStyle(fontSize: 12, fontFamily: 'Poppins', color: Color(0xFF399B25))),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          label: 'Confirm',
          onPressed: () async {
            await _vibrate();
            _handlePasswordConfirm();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF399B25),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool hasError,
    required String errorText,
    required VoidCallback onClearError,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
            color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
              color: Color(0xFF1F1F1F), fontFamily: 'Poppins'),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: hasError ? const Color(0xFFD32F2F) : const Color(0xFFCCCCCC),
                  width: hasError ? 1.0 : 0.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: hasError ? const Color(0xFFD32F2F) : const Color(0xFF399B25), width: 1.5),
            ),
            errorText: hasError ? errorText : null,
            errorStyle: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: Color(0xFFD32F2F)),
          ),
          onChanged: (_) { if (hasError) onClearError(); },
        ),
      ],
    );
  }
}