import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PlantPulse/state/user_state.dart';
import 'recent_scan.dart';
import 'package:dio/dio.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
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

    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, 'Login');
      return;
    }

    // isLoggedIn = true
    await userState.loadPersistedData();

    if (userState.token.isEmpty) {
      Navigator.pushReplacementNamed(context, 'Login');
      return;
    }

    // جيب الـ profile
    bool tokenExpired = false;
    try {
      final dio = Dio();
      final profileRes = await dio.get(
        'https://plant-pules-api.vercel.app/api/v1/users/profile',
        options: Options(headers: {'token': userState.token}),
      );
      final data = profileRes.data['data'];
      final imageUrl = data['profileImage'] as String? ?? '';
      final name = data['name'] as String? ?? '';
      final gender = data['gender'] as String? ?? '';

      if (imageUrl.isNotEmpty) userState.updateProfileImageUrl(imageUrl);
      if (name.isNotEmpty) userState.updateFullName(name);
      if (gender.isNotEmpty) userState.updateGender(gender.toLowerCase());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        tokenExpired = true;
      }
    } catch (_) {}

    if (tokenExpired) {
      await userState.clearAll();
      scansState.clear();
      await saveScans();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'Login');
      return;
    }

    // جيب الـ scans
    try {
      await loadScansFromApi(userState.token, forceRefresh: true);
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
