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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seen') ?? false;
  runApp(MyApp(seen: seen));
}

class MyApp extends StatelessWidget {
  final bool seen;
  const MyApp({super.key, required this.seen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: seen ? 'Login' : 'OnBoardingScreen', //دي عشان تظهر مرة واحدة بس سطر مهم ممنوع المسح
      routes: {
        'HomePage': (context) => HomePage(),
        'Login': (context) => Login(),
        'OnBoardingScreen': (context) => OnBoardingScreen(),
        'Register': (context) => Register(),
        'Forget_Password': (context) => ForgetPassword(),
        'Send_OTP': (context) => SendOTP(),
        'Change_Password': (context) => ChangePassword(),
        'ScanPage': (context) => Scan(),
      },
    );
  }
}