import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:PlantPulse/state/user_state.dart';

class ResetPasswordSheet extends StatefulWidget {
  const ResetPasswordSheet({super.key});

  @override
  State<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _passwordsMatch = false;
  String? _newPasswordError;
  String? _confirmError;

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
        data: {
          'email': userState.email,
          'newPassword': _newPasswordController.text,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      userState.updatePassword(_newPasswordController.text);

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Password changed successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF399B25),
        textColor: Colors.white,
        fontSize: 14,
      );

      Navigator.of(
        context,
      ).popUntil((route) => route.isFirst || route.settings.name == 'HomePage');
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
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
                'Reset Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a new password that is strong and secure',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717171),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              _PasswordField(
                label: 'New Password',
                hint: 'Enter Your New Password',
                controller: _newPasswordController,
                onChanged: _onNewPasswordChanged,
                errorText: _newPasswordError,
              ),
              const SizedBox(height: 16),
              _PasswordField(
                label: 'Confirm New Password',
                hint: 'Re-enter your new password',
                controller: _confirmPasswordController,
                onChanged: _onConfirmChanged,
                errorText: _confirmError,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: mq.size.height * 0.0592,
                child: ElevatedButton(
                  onPressed: _passwordsMatch && !_isLoading
                      ? _handleConfirm
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _passwordsMatch && !_isLoading
                        ? const Color(0xFF399B25)
                        : const Color(0xFFBABABA),
                    disabledBackgroundColor: const Color(0xFFBABABA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Change',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
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
            color: Color(0xFF1F1F1F),
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
