import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password.dart';
import 'forget_password.dart';
import 'home_page.dart';
import 'login.dart';
import 'onboarding.dart';
import 'recent_scan.dart';
import 'register.dart';
import 'result_page.dart';
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
        'HomePage': (_) => const HomePage(),
        'ResultPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>?;
          return ResultPage(
            imagePath: args?['imagePath'] ?? '',
            plantName: args?['plantName'] ?? 'Lettuce',
            status: args?['status'] ?? 'Healthy',
            confidence: args?['confidence'] ?? '—',
          );
        },
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

    // On fresh install: install_token won't exist.
    // Only clear login-related keys — preserve 'seen' so onboarding
    // doesn't show again on reinstall for returning users.
    final installToken = prefs.getString('install_token');
    if (installToken == null) {
      await prefs.remove('savedToken');
      await prefs.remove('savedEmail');
      await prefs.remove('savedFullName');
      await prefs.remove('savedPassword');
      await prefs.remove('savedGender');
      await prefs.remove('savedImagePath');
      await prefs.remove('recentScans');
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('install_token', DateTime.now().toIso8601String());
    }

    final seen = prefs.getBool('seen') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (!seen) {
      Navigator.pushReplacementNamed(context, 'OnBoardingScreen');
      return;
    }

    if (isLoggedIn) {
      await userState.loadPersistedData();

      // Load local cache first for instant display, then sync from server
      await loadScans();
      loadScansFromApi(userState.token);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        'HomePage',
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName,
          'gender': userState.gender,
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