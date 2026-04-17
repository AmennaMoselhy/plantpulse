import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'green_button.dart';
import 'up_green_plant_pulse.dart';
import 'user_state.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  String _email = '';

  bool _passwordsMatch = false;
  String? _newPasswordError;
  String? _confirmError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _email = args?['email'] as String? ?? userState.email;
  }

  static const _resetUrl =
      'https://plant-pules-api.vercel.app/api/v1/password/reset-password';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onNewPasswordChanged(String value) {
    setState(() {
      _newPasswordError = value.isNotEmpty && value.length < 8
          ? 'Password must be at least 8 characters'
          : null;
      if (_confirmPasswordController.text.isNotEmpty) {
        _onConfirmChanged(_confirmPasswordController.text);
      }
    });
  }

  void _onConfirmChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmError = null;
        _passwordsMatch = false;
      } else if (value == _newPasswordController.text) {
        _confirmError = null;
        _passwordsMatch = _newPasswordController.text.length >= 8;
      } else {
        _confirmError = 'Passwords do not match';
        _passwordsMatch = false;
      }
    });
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio();
      await dio.post(
        _resetUrl,
        data: {'email': _email, 'newPassword': _newPasswordController.text},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      userState.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      _showSuccessDialog();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to reset password';
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

  void _showSuccessDialog() {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.053,
            vertical: size.height * 0.0296,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/right.png',
                cacheWidth: 100,
                width: size.width * 0.1,
                height: size.height * 0.0462,
              ),
              SizedBox(height: size.height * 0.0197),
              const Text(
                'Password Changed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.0099),
              const Text(
                'You Can Now Use Your New Password To Log In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.0394),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399B25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('Login', (route) => false),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          const UpGreenPlantPulse(),
          SizedBox(height: size.height * 0.0296),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF399B25),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: size.height * 0.0296),
                _PasswordField(
                  label: 'New Password',
                  hint: 'Enter Your New Password',
                  controller: _newPasswordController,
                  onChanged: _onNewPasswordChanged,
                  errorText: _newPasswordError,
                ),
                SizedBox(height: size.height * 0.0197),
                _PasswordField(
                  label: 'Confirm New Password',
                  hint: 'Re-enter Your New Password',
                  controller: _confirmPasswordController,
                  onChanged: _onConfirmChanged,
                  errorText: _confirmError,
                ),
                SizedBox(height: size.height * 0.0591),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF399B25),
                        ),
                      )
                    : GreenButton(
                        text: 'Confirm Change',
                        onPress: _handleConfirm,
                        isDisabled: !_passwordsMatch,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? errorText;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F1F1F),
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF676767),
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: widget.errorText,
            errorStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD32F2F),
              fontFamily: 'Poppins',
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _hidden
                    ? Icons.visibility_off_outlined
                    : Icons.remove_red_eye_outlined,
                color: const Color(0xFF676767),
                size: 22,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.errorText != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFCCCCCC),
                width: 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.errorText != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF399B25),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
