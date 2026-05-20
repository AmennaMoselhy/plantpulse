import 'package:flutter/material.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({super.key});

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Legal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F1F1F),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF399B25),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF4A4A4A),
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Privacy Policy'),
                  Tab(text: 'Terms of Use'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _LegalContent(sections: _privacySections),
                  _LegalContent(sections: _termsSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection {
  final String title;
  final String content;

  const _LegalSection({required this.title, required this.content});
}

const _privacySections = [
  _LegalSection(
    title: '1. Information We Collect',
    content:
    'We collect information you provide directly, such as your name, email address, and profile photo. We also collect scan data including plant images and results to improve our service.',
  ),
  _LegalSection(
    title: '2. How We Use Your Information',
    content:
    'We use your information to provide and improve Plant Pulse services, personalize your experience, and send you important updates about your account.',
  ),
  _LegalSection(
    title: '3. Data Storage',
    content:
    'Your data is stored securely on our servers. Plant scan images are processed to detect diseases and are stored to maintain your scan history.',
  ),
  _LegalSection(
    title: '4. Data Sharing',
    content:
    'We do not sell or share your personal information with third parties. Your data is only used to provide Plant Pulse services.',
  ),
  _LegalSection(
    title: '5. Your Rights',
    content:
    'You can access, update, or delete your personal data at any time through your profile settings. You may also contact us to request data deletion.',
  ),
  _LegalSection(
    title: '6. Contact Us',
    content:
    'If you have any questions about this Privacy Policy, please contact us through the Contact Us section in your profile.',
  ),
];

const _termsSections = [
  _LegalSection(
    title: '1. Acceptance of Terms',
    content:
    'By using Plant Pulse, you agree to these Terms of Use. If you do not agree, please do not use the app.',
  ),
  _LegalSection(
    title: '2. Use of the App',
    content:
    'Plant Pulse is designed for lettuce plant health scanning. You agree to use the app only for lawful purposes and in a manner that does not harm others.',
  ),
  _LegalSection(
    title: '3. Account Responsibility',
    content:
    'You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately of any unauthorized use of your account.',
  ),
  _LegalSection(
    title: '4. Scan Results',
    content:
    'Scan results are provided for informational purposes only. Plant Pulse does not guarantee 100% accuracy. Always consult an agricultural expert for critical decisions.',
  ),
  _LegalSection(
    title: '5. Intellectual Property',
    content:
    'All content, features, and functionality of Plant Pulse are owned by us and protected by intellectual property laws.',
  ),
  _LegalSection(
    title: '6. Changes to Terms',
    content:
    'We may update these terms from time to time. Continued use of the app after changes means you accept the new terms.',
  ),
];

class _LegalContent extends StatelessWidget {
  final List<_LegalSection> sections;

  const _LegalContent({required this.sections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A4A4A),
                  fontFamily: 'Poppins',
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}