import 'package:flutter/material.dart';

class ResultNameAndBadge extends StatelessWidget {
  final String plantName;
  final String status;
  final bool isHealthy;
  final String? diseaseName;

  const ResultNameAndBadge({
    super.key,
    required this.plantName,
    required this.status,
    required this.isHealthy,
    this.diseaseName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            plantName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
              fontFamily: 'Poppins',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFFEBF5E9)
                      : const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.warning_rounded,
                      size: 14,
                      color: isHealthy
                          ? const Color(0xFF399B25)
                          : const Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isHealthy
                            ? const Color(0xFF399B25)
                            : const Color(0xFFD32F2F),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              if (!isHealthy && diseaseName != null) ...[
                const SizedBox(height: 4),
                Text(
                  diseaseName!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class ResultMessageCard extends StatelessWidget {
  final bool isHealthy;

  const ResultMessageCard({super.key, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    final message = isHealthy
        ? 'Your plant looks healthy! Keep up the good care and continue monitoring regularly.'
        : 'Your plant shows signs of disease. Consider consulting an expert or adjusting care routines.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHealthy ? const Color(0xFFEBF5E9) : const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHealthy
                ? const Color(0xFFA4D19B)
                : const Color(0xFFFFADAD),
            width: 0.6,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isHealthy ? Icons.eco : Icons.healing,
              color: isHealthy
                  ? const Color(0xFF399B25)
                  : const Color(0xFFD32F2F),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultAccuracyRow extends StatelessWidget {
  final bool isHealthy;
  final String safeConfidence;

  const ResultAccuracyRow({
    super.key,
    required this.isHealthy,
    required this.safeConfidence,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF399B25),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      Text(
                        '$safeConfidence%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF399B25),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCA9C), width: 0.4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF8C27),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image Quality',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      Text(
                        isHealthy ? 'Good' : 'Low',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFFFF8C27),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}