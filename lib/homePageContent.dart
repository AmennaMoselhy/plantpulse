import 'dart:io';
import 'package:flutter/material.dart';
import 'user_state.dart';
import 'recentScan.dart';

class HomePageContent extends StatefulWidget {
  final String firstName;
  const HomePageContent({super.key, required this.firstName});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    userState.addListener(_onUserStateChanged);
    recentScans; // نستخدم الـ global list من recentScan.dart
  }

  void _onUserStateChanged() {
    if (mounted) setState(() {});
  }

  // لما يرجع من صفحة recent scan نعمل refresh
  void _goToRecentScan(BuildContext context) async {
    await Navigator.of(context).pushNamed('RecentScan');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    userState.removeListener(_onUserStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final totalScans = recentScans.length;
    final healthyCount = recentScans.where((s) => s.status == 'Healthy').length;
    final diseasedCount = recentScans.where((s) => s.status == 'Diseased').length;

    // أحدث اتنين
    // ✅ آخر اتنين بالترتيب الصح (الأحدث فوق)
    final reversed = recentScans.reversed.toList();
    final latestTwo = reversed.take(2).toList();

    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.0296,
        right: size.width * 0.064,
        left: size.width * 0.064,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi ${widget.firstName}!",
                      style: const TextStyle(color: Color(0XFF1F1F1F), fontWeight: FontWeight.w600, fontSize: 16)),
                  const Text("Check Your Plants' Health Summary",
                      style: TextStyle(color: Color(0XFF4A4A4A), fontSize: 14, fontWeight: FontWeight.w400)),
                ],
              ),
              const Spacer(),
              ClipOval(
                child: userState.profileImagePath != null
                    ? Image.file(File(userState.profileImagePath!), width: 32, height: 32, fit: BoxFit.cover)
                    : Image.asset('assets/profilePic.png', width: 32, height: 32, fit: BoxFit.cover),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.0296),

          const Text("Statistics", style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          // Total Scans
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0XFFEBF5E9),
              border: Border.all(color: const Color(0XFF61AF51), width: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.asset('assets/totalScans.png'),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Scans", style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w500)),
                    Text("$totalScans", style: const TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Healthy & Diseased
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0XFFEBF5E9),
                    border: Border.all(color: const Color(0XFF61AF51), width: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/health.png'),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Healthy", style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("$healthyCount", style: const TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w700)),
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
                    color: const Color(0XFFFFF4E9),
                    border: Border.all(color: const Color(0XFFFFA352), width: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/disease.png'),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Diseased", style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("$diseasedCount", style: const TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Scans header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Scans", style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 16, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => _goToRecentScan(context),
                child: Row(
                  children: const [
                    Text("See More", style: TextStyle(color: Color(0xFF399B25), fontSize: 13, fontWeight: FontWeight.w500)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF399B25)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // أحدث اتنين scans
          if (recentScans.isEmpty)
            const Text("No scans yet", style: TextStyle(fontSize: 13, color: Color(0xFF717171), fontFamily: 'Poppins'))
          else
            ...latestTwo.map((scan) => _MiniScanItem(scan: scan)).toList(),

          const SizedBox(height: 16),

          // Did you know
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0XFFEBF5E9),
              border: Border.all(color: const Color(0XFF61AF51), width: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.asset('assets/didYouKnow.png'),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Did you know?", style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 12, fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      Text(
                        "Overwatering causes yellow leaves . Water only when the top 2 inches of soil feel dry!",
                        style: TextStyle(color: Color(0XFF1F1F1F), fontSize: 10, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _MiniScanItem extends StatelessWidget {
  final ScanRecord scan;
  const _MiniScanItem({required this.scan});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scanDay = DateTime(dt.year, dt.month, dt.day);
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';
    if (scanDay == today) return 'Today, $timeStr';
    return '${dt.month}/${dt.day}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = scan.status == 'Healthy';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(scan.imagePath), width: 56, height: 56, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: const Color(0xFFF5F5F5),
                    child: const Icon(Icons.image_not_supported, color: Color(0xFFCCCCCC)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.plantName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F), fontFamily: 'Poppins')),
                const SizedBox(height: 3),
                Text(_formatTime(scan.scanTime), style: const TextStyle(fontSize: 11, color: Color(0XFF4A4A4A), fontFamily: 'Poppins')),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isHealthy ? const Color(0XFFA4D19B) : const Color(0XFFEB9F9F), width: 0.4),
                  ),
                  child: Text(scan.status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: 'Poppins',
                          color: isHealthy ? const Color(0xFF399B25) : const Color(0xFFD32F2F))),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF4A4A4A)),
        ],
      ),
    );
  }
}