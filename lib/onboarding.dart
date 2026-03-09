import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late List<PageViewModel> _pages;
  final _introKey = GlobalKey<IntroductionScreenState>();
  int _currentPage = 0;

  // ✅ static عشان متتعملش كل build
  static const _pageData = [
    (
      title: "Welcome to PlantPulse!",
      body:
          "Discover, track, and care for your plants easily. Your personal plant companion for a greener life.",
      image: "assets/onboarding1.png",
    ),
    (
      title: "Get Expert Tips",
      body: "Receive daily advice and tips to make your plants thrive",
      image: "assets/onboarding2.png",
    ),
    (
      title: "Care for Your Plants",
      body:
          "Learn how to water, fertilize, and help your plants grow healthy and strong",
      image: "assets/onboarding3.png",
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _pages = _pageData
        .map(
          (data) =>
              _buildPage(context, size, data.title, data.body, data.image),
        )
        .toList();
  }

  Future<void> _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pageData.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          IntroductionScreen(
            key: _introKey,
            globalBackgroundColor: Colors.white,
            pages: _pages,
            showSkipButton: false,
            showNextButton: false,
            showDoneButton: false,
            dotsDecorator: const DotsDecorator(
              size: Size(0, 0),
              activeSize: Size(0, 0),
            ),
            onChange: (index) => setState(() => _currentPage = index),
          ),

          // ✅ Top bar: back + skip
          Positioned(
            top: size.height * 0.084,
            left: size.width * 0.064,
            right: size.width * 0.064,
            child: Row(
              children: [
                if (_currentPage != 0)
                  GestureDetector(
                    onTap: () => _introKey.currentState?.previous(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF4A4A4A),
                      size: 24,
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEDEDED),
                    minimumSize: Size(size.width * 0.064, size.height * 0.0345),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.0023,
                      horizontal: size.width * 0.0567,
                    ),
                  ),
                  onPressed: _navigateToLogin,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Dots
          Positioned(
            bottom: size.height * 0.197,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF399B25)
                        : const Color(0xFFC7C7C7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

          // ✅ Next / Get Started button
          Positioned(
            bottom: size.height * 0.111,
            left: size.width * 0.064,
            right: size.width * 0.064,
            child: SizedBox(
              width: double.infinity,
              height: size.height * 0.0591,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399B25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLastPage
                    ? _navigateToLogin
                    : () => _introKey.currentState?.next(),
                child: Text(
                  isLastPage ? "Get Started" : "Next",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ extracted method بدل class منفصل
  PageViewModel _buildPage(
    BuildContext context,
    Size size,
    String title,
    String body,
    String imagePath,
  ) {
    return PageViewModel(
      title: title,
      body: body,
      image: Image.asset(imagePath, height: size.height * 0.3239),
      decoration: PageDecoration(
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF399B25),
        ),
        bodyTextStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6E6E6E),
          fontWeight: FontWeight.w400,
        ),
        imagePadding: EdgeInsets.only(
          top: size.height * 0.138,
          bottom: size.height * 0.0394,
          left: size.width * 0.149,
          right: size.width * 0.149,
        ),
        titlePadding: EdgeInsets.only(
          right: size.width * 0.064,
          left: size.width * 0.064,
          bottom: size.height * 0.0099,
        ),
        bodyPadding: EdgeInsets.only(
          right: size.width * 0.064,
          left: size.width * 0.064,
        ),
      ),
    );
  }
}
