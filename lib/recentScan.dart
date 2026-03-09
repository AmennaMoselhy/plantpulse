import 'dart:io';
import 'package:flutter/material.dart';

// Model
class ScanRecord {
  final String imagePath;
  final String plantName;
  final String status;
  final DateTime scanTime;

  ScanRecord({
    required this.imagePath,
    required this.plantName,
    required this.status,
    required this.scanTime,
  });
}

// Global list يتشارك بين الصفحات
final List<ScanRecord> recentScans = [];

class RecentScan extends StatefulWidget {
  const RecentScan({super.key});

  @override
  State<RecentScan> createState() => _RecentScanState();
}

class _RecentScanState extends State<RecentScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: Color(0xFF4A4A4A)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Recent Scan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F1F1F), fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (recentScans.isEmpty) return;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: const Text('Clear All?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16)),
                          content: const Text('Are you sure you want to delete all recent scans?', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF717171))),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: Color(0xFF399B25), fontFamily: 'Poppins')),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => recentScans.clear());
                                Navigator.pop(context);
                              },
                              child: const Text('Clear', style: TextStyle(color: Color(0xFFD32F2F), fontFamily: 'Poppins')),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.delete_outline_rounded, size: 24, color: Color(0xFFD32F2F)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: recentScans.isEmpty
                  ? const Center(
                child: Text(
                  'No scans yet',
                  style: TextStyle(fontSize: 14, color: Color(0xFF717171), fontFamily: 'Poppins'),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: recentScans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final actualIndex = recentScans.length - 1 - index;
                  final scan = recentScans[actualIndex];
                  return Dismissible(
                    key: Key(scan.imagePath + scan.scanTime.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F), size: 24),
                    ),
                    onDismissed: (_) {
                      setState(() => recentScans.removeAt(actualIndex));
                    },
                    child: _ScanItem(scan: scan),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanItem extends StatelessWidget {
  final ScanRecord scan;

  const _ScanItem({required this.scan});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final scanDay = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (scanDay == today) return 'Today, $timeStr';
    if (scanDay == yesterday) return 'Yesterday, $timeStr';
    return '${dt.month}/${dt.day}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = scan.status == 'Healthy';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(scan.imagePath),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64, height: 64,
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.image_not_supported, color: Color(0xFFCCCCCC)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.plantName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text(_formatTime(scan.scanTime), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0XFF4A4A4A), fontFamily: 'Poppins')),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHealthy ? const Color(0XFFA4D19B) : const Color(0XFFEB9F9F),
                      width: 0.4,
                    ),
                  ),
                  child: Text(
                    scan.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: isHealthy ? const Color(0xFF399B25) : const Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF4A4A4A)),
        ],
      ),
    );
  }
}