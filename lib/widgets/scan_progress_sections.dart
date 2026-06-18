import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'primary_button.dart';

class ScanProgressSection extends StatelessWidget {
  final double progress;

  const ScanProgressSection({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 21),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5E9),
                  border: Border.all(
                    color: const Color(0xFF399B25),
                    width: 1.6,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Scanning in progress... $percent%',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFF5F5F5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF399B25)),
          ),
        ),
      ],
    );
  }
}

class ScanSuccessSection extends StatelessWidget {
  final String? apiError;
  final bool isNetworkError;
  final VoidCallback onRetry;
  final VoidCallback onSeeResult;

  const ScanSuccessSection({
    super.key,
    required this.apiError,
    required this.isNetworkError,
    required this.onRetry,
    required this.onSeeResult,
  });

  @override
  Widget build(BuildContext context) {
    if (apiError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFADAD), width: 0.4),
            ),
            child: Row(
              children: [
                Icon(
                  isNetworkError
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  color: const Color(0xFFD32F2F),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    apiError!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD32F2F),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GreenButton(
            text: 'Try Again',
            onPress: () async {
              if (await Vibration.hasVibrator() == true) {
                Vibration.vibrate(duration: 30);
              } else {
                HapticFeedback.lightImpact();
              }
              onRetry();
            },
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outlined,
              color: Color(0xFF399B25),
              size: 30,
            ),
            SizedBox(width: 4),
            Text(
              'Scan Completed Successfully',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF399B25),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "We've identified your plant species and health condition",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 20),
        GreenButton(
          text: 'See Result',
          onPress: () async {
            if (await Vibration.hasVibrator() == true) {
              Vibration.vibrate(duration: 50);
            } else {
              HapticFeedback.mediumImpact();
            }
            onSeeResult();
          },
        ),
      ],
    );
  }
}