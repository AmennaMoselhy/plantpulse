import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'change_password.dart';
import 'forget_password.dart';
import 'home_page.dart';
import 'login.dart';
import 'onboarding.dart';
import 'recent_scan.dart';
import 'register.dart';
import 'resultpage.dart';
import 'scan.dart';
import 'send_otp.dart';
import 'user_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),

      home: const _StartupScreen(),

      routes: {
        'Login': (_) => const Login(),
        'Change_Password': (_) => const ChangePassword(),
        'OnBoardingScreen': (_) => const OnBoardingScreen(),
        'Register': (_) => const Register(),
        'Forget_Password': (_) => const ForgotPassword(),
        'Send_OTP': (_) => const SendOTP(),
        'ScanPage': (_) => const Scan(),
        'RecentScan': (_) => const RecentScan(),

        // ⚠️ مهم: هنا التعديل الوحيد المطلوب
        'HomePage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>?;

          return HomePage(
            firstName: args?['firstName'] ?? '',
            gender: args?['gender'] ?? '',
          );
        },

        'ResultPage': (_) => ResultPage(
          imagePath: '',
          plantName: 'Lettuce',
          status: 'Healthy',
          confidence: '—',
        ),
      },
    );
  }
}
