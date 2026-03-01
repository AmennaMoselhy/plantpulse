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


  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String firstName = args['firstName'];
    final String fullName = args['fullName'];
    final List<Widget> _pages = [
      HomePageContent(firstName: firstName),
      Scan(),
      RecentScan(),
      Profile(fullName: fullName),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEBF5E9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Color(0XFFEBF5E9),
            selectedItemColor: Color(0xFF399B25),
            unselectedItemColor: Color(0xFF4A4A4A),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            items: [
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 0 ? Color(0xFF399B25) : Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/home.png', width: 24, height: 24),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 1 ? Color(0xFF399B25) : Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/scan.png', width: 24, height: 24),
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 2 ? Color(0xFF399B25) : Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/recentScan.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                label: 'Recent Scan',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 3 ? Color(0xFF399B25) : Color(0xFF4A4A4A),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/profile.png',
                    width: 24,
                    height: 24,
                  ),
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
