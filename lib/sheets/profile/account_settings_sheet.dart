import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import 'package:PlantPulse/state/user_state.dart';
import 'package:PlantPulse/screens/recent_scan.dart';
import 'package:PlantPulse/app_navigator.dart';
import 'package:PlantPulse/screens/legal_page.dart';
import 'change_password_sheet.dart';

class AccountSettingsSheet extends StatefulWidget {
  const AccountSettingsSheet({super.key});

  @override
  State<AccountSettingsSheet> createState() => _AccountSettingsSheetState();
}

class _AccountSettingsSheetState extends State<AccountSettingsSheet> {
  bool _deletingAccount = false;

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.w700,
                fontFamily: 'Poppins', color: Color(0xFFD32F2F))),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF399B25), fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFD32F2F), fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _deletingAccount = true);

    try {
      final dio = Dio();
      await dio.delete(
        'https://plant-pules-api.vercel.app/api/v1/users/profile',
        options: Options(headers: {'token': userState.token}),
      );
      await userState.clearAll();
      scansState.clear();
      await saveScans();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('Login', (r) => false);
      Fluttertoast.showToast(
        msg: 'Account deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 14,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete account. Please try again.',
              style: TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, fadeSlideRoute(const LegalPage()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Color(0xFF399B25), size: 24),
                  SizedBox(width: 12),
                  Expanded(child: Text('Privacy & Terms',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins', color: Color(0xFF184110)))),
                  Icon(Icons.arrow_forward_ios_rounded, size: 19, color: Color(0xFF222222)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => const ChangePasswordSheet(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset('assets/password-check.png', width: 24, height: 24),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Change Password',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins', color: Color(0xFF184110)))),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 19, color: Color(0xFF222222)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _deletingAccount ? null : () async {
              if (await Vibration.hasVibrator() == true) {
                Vibration.vibrate(duration: 100);
              } else {
                HapticFeedback.heavyImpact();
              }
              _handleDeleteAccount();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                border: Border.all(color: const Color(0xFFFFADAD), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 24),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Delete Account',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins', color: Color(0xFFD32F2F)))),
                  if (_deletingAccount)
                    const SizedBox(width: 19, height: 19,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD32F2F)))
                  else
                    const Icon(Icons.arrow_forward_ios_rounded, size: 19, color: Color(0xFFD32F2F)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}