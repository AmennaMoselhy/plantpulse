import 'package:flutter/material.dart';
import 'forgot_password_sheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'user_state.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordsMatch = false;
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCurrentPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _currentPasswordError = null;
      } else if (value != userState.password) {
        _currentPasswordError = 'Incorrect current password';
      } else {
        _currentPasswordError = null;
      }
    });
  }

  void _onNewPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _newPasswordError = null;
      } else if (value.length < 8) {
        _newPasswordError = 'Password must be at least 8 characters';
      } else {
        _newPasswordError = null;
      }
      // ✅ يحدث الـ confirm error لو كان فيه نص
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
        _passwordsMatch = true;
      } else {
        _confirmError = 'Passwords do not match';
        _passwordsMatch = false;
      }
    });
  }

  void _handleConfirm() {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    // ✅ تأكد من الباسورد الحالي
    if (currentPassword != userState.password) {
      setState(() => _currentPasswordError = 'Incorrect current password');
      return;
    }

    // ✅ تأكد من الباسورد الجديد
    if (newPassword.length < 8) {
      setState(() => _newPasswordError = 'Password must be at least 8 characters');
      return;
    }

    if (!_passwordsMatch) return;

    // ✅ حفظ الباسورد الجديد
    userState.updatePassword(newPassword);

    Navigator.pop(context);

    Fluttertoast.showToast(
      msg: "Password changed successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFF399B25),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              const Text('Create a new password that is strong and secure',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0XFF717171), fontFamily: 'Poppins')),
              const SizedBox(height: 24),

              _buildPasswordField(
                label: 'Current Password',
                hint: 'Enter Your Current Password',
                controller: _currentPasswordController,
                onChanged: _onCurrentPasswordChanged,
                errorText: _currentPasswordError,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (context) => const ForgotPasswordSheet(),
                  ),
                  child: const Text('Forget Your Password?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0XFF286E1A),
                          fontFamily: 'Poppins', decoration: TextDecoration.underline, decorationColor: Color(0XFF286E1A))),
                ),
              ),
              const SizedBox(height: 12),

              _buildPasswordField(
                label: 'New Password',
                hint: 'Enter Your New Password',
                controller: _newPasswordController,
                onChanged: _onNewPasswordChanged,
                errorText: _newPasswordError,
              ),
              const SizedBox(height: 12),

              _buildPasswordField(
                label: 'Confirm New Password',
                hint: 'Re-enter your new password',
                controller: _confirmPasswordController,
                onChanged: _onConfirmChanged,
                errorText: _confirmError,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _passwordsMatch ? _handleConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _passwordsMatch ? const Color(0xFF399B25) : const Color(0XFFBABABA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: const Color(0xFFBABABA),
                  ),
                  child: const Text('Confirm Change',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool hidden = true;
        return StatefulBuilder(
          builder: (context, setToggleState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  obscureText: hidden,
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F1F1F), fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF676767), fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    errorText: errorText,
                    errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFD32F2F), fontFamily: 'Poppins'),
                    suffixIcon: IconButton(
                      icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined,
                          color: const Color(0xFF676767), size: 22),
                      onPressed: () => setToggleState(() => hidden = !hidden),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: errorText != null ? const Color(0xFFD32F2F) : const Color(0xFFCCCCCC), width: 0.6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: errorText != null ? const Color(0xFFD32F2F) : const Color(0xFF399B25), width: 1.5),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}