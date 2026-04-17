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
        'HomePage': (_) => const HomePage(),
        'Login': (_) => const Login(),
        'Change_Password': (_) => const ChangePassword(),
        'OnBoardingScreen': (_) => const OnBoardingScreen(),
        'Register': (_) => const Register(),
        'Forget_Password': (_) => const ForgotPassword(),
        'Send_OTP': (_) => const SendOTP(),
        'ScanPage': (_) => const Scan(),
        'RecentScan': (_) => const RecentScan(),
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
    await loadScans();
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (!seen) {
      Navigator.pushReplacementNamed(context, 'OnBoardingScreen');
      return;
    }

    if (isLoggedIn) {
      await userState.loadPersistedData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        'HomePage',
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName,
          'email': userState.email,
          'password': '',
        },
      );
      return;
    }

    Navigator.pushReplacementNamed(context, 'Login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}
