import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:PlantPulse/screens/change_password.dart';
import 'package:PlantPulse/screens/forget_password.dart';
import 'package:PlantPulse/screens/home_page.dart';
import 'package:PlantPulse/screens/login.dart';
import 'package:PlantPulse/screens/onboarding.dart';
import 'package:PlantPulse/screens/recent_scan.dart';
import 'package:PlantPulse/screens/register.dart';
import 'package:PlantPulse/screens/scan.dart';
import 'package:PlantPulse/screens/send_otp.dart';
import 'package:PlantPulse/screens/startup_screen.dart';

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
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const StartupScreen(),
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
