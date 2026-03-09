import 'package:PlantPulse/homePageContent.dart';
import 'package:flutter/material.dart';
import 'recentScan.dart';
import 'profile.dart';
import 'scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _firstName = '';
  String _fullName = '';
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    // ✅ بناخد الـ args مرة واحدة بس عشان مش يرجع للقديم
    if (!_initialized) {
      _firstName = args['firstName'];
      _fullName = args['fullName'];
      _initialized = true;
    }

    final List<Widget> pages = [
      HomePageContent(firstName: _firstName),
      const Scan(),
      const RecentScan(),
      Profile(
        fullName: _fullName,
        onNameChanged: (newName) {
          setState(() {
            _firstName = newName.split(' ')[0];
            _fullName = newName;
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEBF5E9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: const Color(0XFFEBF5E9),
            selectedItemColor: const Color(0xFF399B25),
            unselectedItemColor: const Color(0xFF4A4A4A),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
            items: [
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 0 ? const Color(0xFF399B25) : const Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/home.png', width: 24, height: 24),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 1 ? const Color(0xFF399B25) : const Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/scan.png', width: 24, height: 24),
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 2 ? const Color(0xFF399B25) : const Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/recentScan.png', width: 24, height: 24),
                ),
                label: 'Recent Scan',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 3 ? const Color(0xFF399B25) : const Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/profile.png', width: 24, height: 24),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}