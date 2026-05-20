import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password.dart';
import 'forget_password.dart';
import 'home_page.dart';
import 'login.dart';
import 'onboarding.dart';
import 'recent_scan.dart';
import 'register.dart';
import 'scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'send_otp.dart';
import 'user_state.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  try {
    await _scheduleDailyNotification();
  } catch (e) {
    debugPrint('Notification error: $e');
  }

  runApp(const MyApp());
}

Future<void> _scheduleDailyNotification() async {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12, 36);

  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '🌱 Plant Pulse',
    'Don\'t forget to check your plant health again!',
    scheduled,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Daily plant check reminder',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      home: const _StartupScreen(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case 'Login':
            page = const Login();
          case 'Change_Password':
            page = const ChangePassword();
          case 'OnBoardingScreen':
            page = const OnBoardingScreen();
          case 'Register':
            page = const Register();
          case 'Forget_Password':
            page = const ForgotPassword();
          case 'Send_OTP':
            page = const SendOTP();
          case 'ScanPage':
            page = const Scan();
          case 'RecentScan':
            page = const RecentScan();
          case 'HomePage':
            page = const HomePage();
          default:
            page = const Login();
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();

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

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (!seen) {
      Navigator.pushReplacementNamed(context, 'OnBoardingScreen');
      return;
    }

    if (isLoggedIn) {
      try {
        await userState.loadPersistedData();
        await loadScans();
        loadScansFromApi(userState.token);
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        'HomePage',
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName.isNotEmpty
              ? userState.fullName
              : 'User',
          'gender': userState.gender.isNotEmpty ? userState.gender : 'male',
        },
      );
      return;
    }
    Navigator.pushReplacementNamed(context, 'Login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/leaf.png',
                  width: size.width * 0.1,
                  height: size.width * 0.1,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/plantpulse.png',
                  width: size.width * 0.45,
                  errorBuilder: (_, __, ___) => const Text(
                    'Plant Pulse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF399B25),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF399B25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
