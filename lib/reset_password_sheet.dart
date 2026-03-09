import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordSheet extends StatefulWidget {
  const ResetPasswordSheet({super.key});

  @override
  State<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordsMatch = false;
  String? _confirmError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  void _onNewPasswordChanged(String value) {
    if (_confirmPasswordController.text.isNotEmpty) {
      _onConfirmChanged(_confirmPasswordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF717171),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'New Password',
                hint: 'Enter Your New Password',
                controller: _newPasswordController,
                onChanged: _onNewPasswordChanged,
              ),
              const SizedBox(height: 16),

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
                  onPressed: _passwordsMatch
                      ? () {
                          Navigator.of(context).popUntil(
                            (route) =>
                                route.isFirst ||
                                route.settings.name == 'HomePage',
                          );
                          Fluttertoast.showToast(
                            msg: "Password changed successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: const Color(0xFF399B25),
                            textColor: Colors.white,
                            fontSize: 14,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _passwordsMatch
                        ? const Color(0xFF399B25)
                        : const Color(0xFFBABABA),
                    disabledBackgroundColor: const Color(0xFFBABABA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F1F1F),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  obscureText: hidden,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1F1F1F),
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF676767),
                      fontFamily: 'Poppins',
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    errorText: errorText,
                    errorStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidden
                            ? Icons.visibility_off_outlined
                            : Icons.remove_red_eye_outlined,
                        color: const Color(0xFF676767),
                        size: 22,
                      ),
                      onPressed: () => setToggleState(() => hidden = !hidden),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: errorText != null
                            ? Colors.red
                            : const Color(0xFFCCCCCC),
                        width: 0.6,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: errorText != null
                            ? Colors.red
                            : const Color(0xFF399B25),
                        width: 1.5,
                      ),
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
