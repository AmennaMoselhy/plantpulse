import 'scan.dart';
import 'package:flutter/material.dart';
import 'forgetPassword.dart';
import 'sendOTP.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding.dart';
import 'login.dart';
import 'homePage.dart';
import 'changePassword.dart';
import 'recentScan.dart';

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
      home: const _StartupScreen(), // ✅ بدل initialRoute
      routes: {
        'HomePage': (context) => HomePage(),
        'Login': (context) => const Login(),
        'OnBoardingScreen': (context) => const OnBoardingScreen(),
        'Register': (context) => const Register(),
        'Forget_Password': (context) => ForgetPassword(),
        'Send_OTP': (context) => SendOTP(),
        'Change_Password': (context) => ChangePassword(),
        'ScanPage': (context) => const Scan(),
        'RecentScan': (context) => const RecentScan(),
      },
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen') ?? false;
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      seen ? 'Login' : 'OnBoardingScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ شاشة بيضاء ريحة لحد ما يقرر يروح فين
    return const Scaffold(backgroundColor: Colors.white);
  }
}
