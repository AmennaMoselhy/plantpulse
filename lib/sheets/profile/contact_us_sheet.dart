import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:PlantPulse/state/user_state.dart';

class ContactUsSheet extends StatefulWidget {
  const ContactUsSheet({super.key});

  @override
  State<ContactUsSheet> createState() => _ContactUsSheetState();
}

class _ContactUsSheetState extends State<ContactUsSheet> {
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _messageError;

  static const _contactUrl =
      'https://plant-pules-api.vercel.app/api/v1/contact/message';

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _messageError = 'Message is required');
      return;
    }
    setState(() {
      _isLoading = true;
      _messageError = null;
    });

    try {
      final fullName = userState.fullName;
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final dio = Dio();
      await dio.post(
        _contactUrl,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': userState.email,
          'phone': _phoneController.text.trim().isEmpty
              ? '00000000000'
              : _phoneController.text.trim(),
          'message': message,
        },
        options: Options(
          headers: {'token': userState.token},
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Message sent successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF399B25),
        textColor: Colors.white,
        fontSize: 14,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to send message';
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
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Send us a message and we will get back to you',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717171),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Phone (optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFCCCCCC),
                      width: 0.6,
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
              ),
              const SizedBox(height: 16),
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                onChanged: (_) {
                  if (_messageError != null) {
                    setState(() => _messageError = null);
                  }
                },
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'Write your message here...',
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
                  errorText: _messageError,
                  errorStyle: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFD32F2F),
                    fontFamily: 'Poppins',
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _messageError != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFCCCCCC),
                      width: 0.6,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _messageError != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF399B25),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399B25),
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
                          'Send Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
