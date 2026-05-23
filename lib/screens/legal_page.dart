import 'package:flutter/material.dart';
import 'package:PlantPulse/data/legal_data.dart';

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
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 24, color: Color(0xFF4A4A4A)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Legal',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F1F1F),
                              fontFamily: 'Poppins')),
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
                labelStyle: const TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400, fontSize: 13),
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
                  _LegalContent(sections: privacySections),
                  _LegalContent(sections: termsSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalContent extends StatelessWidget {
  final List<LegalSection> sections;

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
              Text(section.title,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                      fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Text(section.content,
                  style: const TextStyle(fontSize: 13,
                      color: Color(0xFF4A4A4A),
                      fontFamily: 'Poppins',
                      height: 1.6)),
            ],
          ),
        );
      },
    );
  }
}