import 'package:flutter/material.dart';
import 'home_page_content.dart';
import 'recent_scan.dart';
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
  String _gender = '';
  bool _initialized = false;
  late List<Widget> _pages;

  static const _navItems = [
    (icon: 'assets/home.png', label: 'Home'),
    (icon: 'assets/scan.png', label: 'Scan'),
    (icon: 'assets/recentScan.png', label: 'Recent Scan'),
    (icon: 'assets/profile.png', label: 'Profile'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _firstName = args?['firstName'] ?? '';
      _fullName = args?['fullName'] ?? '';
      _gender = (args?['gender'] ?? 'female').toString();
      _initialized = true;
      _pages = _buildPages();
    }
  }

  List<Widget> _buildPages() {
    return [
      HomePageContent(
        firstName: _firstName,
        gender: _gender,
        onProfileTap: () => setState(() => _currentIndex = 3),
      ),
      const Scan(),
      const RecentScan(),
      Profile(
        fullName: _fullName,
        gender: _gender,
        onNameChanged: (newName) {
          setState(() {
            _firstName = newName.split(' ')[0];
            _fullName = newName;
            _pages[0] = HomePageContent(
              firstName: _firstName,
              gender: _gender,
              onProfileTap: () => setState(() => _currentIndex = 3),
            );
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEBF5E9),
          borderRadius: BorderRadius.only(
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
            backgroundColor: const Color(0xFFEBF5E9),
            selectedItemColor: const Color(0xFF399B25),
            unselectedItemColor: const Color(0xFF4A4A4A),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            items: List.generate(
              _navItems.length,
              (index) => BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == index
                        ? const Color(0xFF399B25)
                        : const Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    _navItems[index].icon,
                    width: 24,
                    height: 24,
                    cacheWidth: 48,
                  ),
                ),
                label: _navItems[index].label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
