import 'package:flutter/material.dart';

class ResultCareTips extends StatelessWidget {
  final bool isHealthy;
  final String? diseaseName;
  final String? description;
  final String? treatment;

  const ResultCareTips({
    super.key,
    required this.isHealthy,
    this.diseaseName,
    this.description,
    this.treatment,
  });

  List<String> _parseTreatment(String treatment) {
    if (treatment.contains('|||')) {
      return treatment
          .split('|||')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    String cleaned = treatment.trim();
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    return cleaned
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasApiData =
        !isHealthy && (diseaseName != null || treatment != null);

    final tips = isHealthy
        ? [
      'Water regularly and avoid overwatering',
      'Ensure adequate sunlight exposure',
      'Use well-draining soil',
      'Apply balanced fertilizer monthly',
    ]
        : treatment != null
        ? _parseTreatment(treatment!)
        : [
      'Remove infected leaves immediately',
      'Improve air circulation around the plant',
      'Avoid wetting leaves when watering',
      'Consider using appropriate fungicide or pesticide',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF5E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/lamp.png', width: 24, height: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHealthy
                        ? 'Care Tips for Ongoing Health'
                        : hasApiData && diseaseName != null
                        ? 'Treatment: $diseaseName'
                        : 'Recommended Treatment Steps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ],
            ),
            if (!isHealthy && description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontFamily: 'Poppins',
                  color: Color(0xFF717171),
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...tips.map(
                  (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF399B25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}