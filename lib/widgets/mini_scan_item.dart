import 'dart:io';
import 'package:flutter/material.dart';
import 'package:PlantPulse/screens/recent_scan.dart';
import 'package:PlantPulse/screens/result_page.dart';
import 'package:PlantPulse/app_navigator.dart';

class MiniScanItem extends StatelessWidget {
  final ScanRecord scan;

  const MiniScanItem({super.key, required this.scan});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scanDay = DateTime(dt.year, dt.month, dt.day);
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    if (scanDay == today) return 'Today, $hour:$minute $period';
    return '${dt.month}/${dt.day}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = scan.status == 'Healthy';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        fadeSlideRoute(
          ResultPage(
            imagePath: scan.imagePath,
            plantName: scan.plantName,
            status: scan.status,
            confidence: scan.confidence,
            imageUrl: scan.imageUrl,
            fromRecentScan: true,
            diseaseName: scan.diseaseName,
            description: scan.description,
            treatment: scan.treatment,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: scan.imageUrl != null && scan.imageUrl!.isNotEmpty
                  ? Image.network(
                scan.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.image_not_supported,
                      color: Color(0xFFCCCCCC)),
                ),
              )
                  : Image.file(
                File(scan.imagePath),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.image_not_supported,
                      color: Color(0xFFCCCCCC)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.plantName,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 3),
                  Text(_formatTime(scan.scanTime),
                      style: const TextStyle(fontSize: 11,
                          color: Color(0xFF4A4A4A),
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHealthy
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHealthy
                            ? const Color(0xFFA4D19B)
                            : const Color(0xFFEB9F9F),
                        width: 0.4,
                      ),
                    ),
                    child: Text(scan.status,
                        style: TextStyle(fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: isHealthy
                                ? const Color(0xFF399B25)
                                : const Color(0xFFD32F2F))),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF4A4A4A)),
          ],
        ),
      ),
    );
  }
}