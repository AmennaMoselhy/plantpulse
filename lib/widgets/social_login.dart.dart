import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginWithFaceBook extends StatefulWidget {
  final void Function(String email)? onEmailSelected;

  const LoginWithFaceBook({super.key, this.onEmailSelected});

  @override
  State<LoginWithFaceBook> createState() => _LoginWithFaceBookState();
}

class _LoginWithFaceBookState extends State<LoginWithFaceBook> {
  bool _googleLoading = false;

  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '700313409379-pb5dksc6o8354hskos7itgc5mnolhtoq.apps.googleusercontent.com',
  );

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) return;
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F1F1),
                ),
                child: Image.asset(
                  'assets/google_logo.png',
                  height: 32,
                  width: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Google login is not available yet.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399B25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await _googleSignIn.signOut();
    } catch (e) {
      _showError('Google sign in failed');
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  void _showComingSoon() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F1F1),
              ),
              child: const Icon(
                Icons.facebook,
                color: Color(0xFF1877F2),
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Facebook login is not available yet.\nPlease try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399B25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final logoSize = size.height * 0.0296;
    final logoWidth = size.width * 0.064;

    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
          child: Column(
            children: [
              const Text(
                'Or login with',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF399B25),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.0296),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showComingSoon,
                    child: Image.asset(
                      'assets/facebook_logo.png',
                      height: logoSize,
                      width: logoWidth,
                      cacheHeight: logoSize.toInt(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _googleLoading ? null : _signInWithGoogle,
                    child: _googleLoading
                        ? SizedBox(
                            width: logoWidth,
                            height: logoSize,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF399B25),
                            ),
                          )
                        : Image.asset(
                            'assets/google_logo.png',
                            height: logoSize,
                            width: logoWidth,
                            cacheHeight: logoSize.toInt(),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFC7C7C7), thickness: 1)),
      ],
    );
  }
}
