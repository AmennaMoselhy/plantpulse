import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'What plants does Plant Pulse support?',
      answer:
      'Currently, Plant Pulse supports lettuce plants only. We are working on adding more plant types in future updates.',
    ),
    _FaqItem(
      question: 'How accurate are the scan results?',
      answer:
      'Our AI model provides high accuracy results, but scan results are for informational purposes only. For critical decisions, always consult an agricultural expert.',
    ),
    _FaqItem(
      question: 'Why is my scan showing "Unsupported Plant"?',
      answer:
      'This means the image does not contain a lettuce plant. Make sure the lettuce is clearly visible and well-lit in the photo.',
    ),
    _FaqItem(
      question: 'How do I get better scan results?',
      answer:
      'Make sure the plant is clearly visible, well-lit, and centered in the photo. Avoid blurry or dark images for best results.',
    ),
    _FaqItem(
      question: 'Can I delete my scan history?',
      answer:
      'Yes! Go to Recent Scan and tap the delete icon to clear all scans, or swipe left on a single scan to delete it.',
    ),
    _FaqItem(
      question: 'How do I change my profile photo?',
      answer:
      'Go to Profile, tap on your photo, then choose "Change photo" to select a new image from your gallery.',
    ),
    _FaqItem(
      question: 'How do I delete my account?',
      answer:
      'Go to Profile → Account Settings → Delete Account. Note that this action is permanent and cannot be undone.',
    ),
    _FaqItem(
      question: 'Is my data safe?',
      answer:
      'Yes. We take your privacy seriously. Your data is stored securely and never shared with third parties. Read our Privacy Policy for more details.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final topPadding = mq.padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.15 + topPadding,
            padding: EdgeInsets.only(top: topPadding, left: 8,),
            decoration: const BoxDecoration(
              color: Color(0x47A4D19B),
            ),
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
                const SizedBox(width: 24),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Frequently asked questions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A4A4A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _FaqCard(faq: _faqs[index]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _FaqCard extends StatefulWidget {
  final _FaqItem faq;

  const _FaqCard({required this.faq});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _expanded ? const Color(0xFFEBF5E9) : Colors.white,
          border: Border.all(
            color: _expanded
                ? const Color(0xFF61AF51)
                : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
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
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF399B25),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF399B25),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFD0E8C8), thickness: 0.5),
              const SizedBox(height: 8),
              Text(
                widget.faq.answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A4A4A),
                  fontFamily: 'Poppins',
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}