import 'dart:io';
import 'package:flutter/material.dart';
import 'user_state.dart';
import 'recent_scan.dart';
import 'resultpage.dart';

class HomePageContent extends StatefulWidget {
  final String firstName;
  final String gender;
  final VoidCallback? onProfileTap;

  const HomePageContent({
    super.key,
    required this.firstName,
    required this.gender,
    this.onProfileTap,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    userState.addListener(_onStateChanged);
    scansState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _goToRecentScan() async {
    await Navigator.of(context).pushNamed('RecentScan');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    userState.removeListener(_onStateChanged);
    scansState.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scans = scansState.scans;
    final latestTwo = scans.reversed.take(2).toList();

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
          _buildHeader(),
          SizedBox(height: size.height * 0.0296),
          const Text(
            'Statistics',
            style: TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            imagePath: 'assets/totalScans.png',
            label: 'Total Scans',
            value: '${scans.length}',
            bgColor: const Color(0xFFEBF5E9),
            borderColor: const Color(0xFF61AF51),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  imagePath: 'assets/health.png',
                  label: 'Healthy',
                  value: '${scans.where((s) => s.status == 'Healthy').length}',
                  bgColor: const Color(0xFFEBF5E9),
                  borderColor: const Color(0xFF61AF51),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  imagePath: 'assets/disease.png',
                  label: 'Diseased',
                  value: '${scans.where((s) => s.status == 'Diseased').length}',
                  bgColor: const Color(0xFFFFF4E9),
                  borderColor: const Color(0xFFFFA352),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: _goToRecentScan,
                child: const Row(
                  children: [
                    Text(
                      'See More',
                      style: TextStyle(
                        color: Color(0xFF399B25),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFF399B25),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (scansState.isEmpty)
            const Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF717171),
                fontFamily: 'Poppins',
              ),
            )
          else
            ...latestTwo.map(
              (scan) => _MiniScanItem(scan: scan),
            ),
          const SizedBox(height: 16),
          _buildDidYouKnow(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${widget.firstName}!',
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Text(
              "Check Your Plants' Health Summary",
              style: TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onProfileTap,
          child: ClipOval(
            child: userState.profileImagePath != null
                ? Image.file(
                    File(userState.profileImagePath!),
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    cacheWidth: 64,
                  )
                : Image.asset(
                    userState.gender.toLowerCase() == 'female'
                        ? 'assets/bigProfilePic.png'
                        : 'assets/male.png',
                    width: 34,
                    height: 32,
                    fit: BoxFit.cover,
                    cacheWidth: 64,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String imagePath,
    required String label,
    required String value,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 24, height: 24, cacheWidth: 48),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDidYouKnow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5E9),
        border: Border.all(color: const Color(0xFF61AF51), width: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/didYouKnow.png',
            width: 24,
            height: 24,
            cacheWidth: 48,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Did you know?',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Overwatering causes yellow leaves. Water only when the top 2 inches of soil feel dry!',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
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
        MaterialPageRoute(
          builder: (_) => ResultPage(
            imagePath: scan.imagePath,
            plantName: scan.plantName,
            status: scan.status,
            confidence: scan.confidence,
            imageUrl: scan.imageUrl,
            fromRecentScan: true,
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
              color: Colors.black.withOpacity(0.04),
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
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFFCCCCCC),
                        ),
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
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.plantName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(scan.scanTime),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4A4A4A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
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
                    child: Text(
                      scan.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: isHealthy
                            ? const Color(0xFF399B25)
                            : const Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF4A4A4A),
            ),
          ],
        ),
      ),
    );
  }
}
