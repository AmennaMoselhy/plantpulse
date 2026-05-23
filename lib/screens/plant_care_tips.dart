import 'package:flutter/material.dart';
import 'package:PlantPulse/data/plant_care_data.dart';

class PlantCareTips extends StatelessWidget {
  const PlantCareTips({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final topPadding = mq.padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.15 + topPadding,
            padding: EdgeInsets.only(top: topPadding, left: 24, right: 24),
            decoration: const BoxDecoration(color: Color(0x47A4D19B)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🥬 Lettuce Care Tips',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
                SizedBox(height: 4),
                Text('Everything you need to grow healthy lettuce',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400,
                        color: Color(0xFF4A4A4A), fontFamily: 'Poppins')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: plantCareCategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _TipCard(category: plantCareCategories[index]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TipCard extends StatefulWidget {
  final TipCategory category;

  const _TipCard({required this.category});

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
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
            color: _expanded ? const Color(0xFF61AF51) : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEBF5E9),
                      borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(widget.category.image,
                        width: 48, height: 48, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.eco, color: Color(0xFF399B25), size: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.category.title,
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF399B25),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFD0E8C8), thickness: 0.5),
              const SizedBox(height: 8),
              ...widget.category.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(
                        color: Color(0xFF399B25),
                        fontWeight: FontWeight.w700, fontSize: 16)),
                    Expanded(child: Text(tip, style: const TextStyle(
                        fontSize: 13, color: Color(0xFF4A4A4A),
                        fontFamily: 'Poppins', height: 1.5))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}