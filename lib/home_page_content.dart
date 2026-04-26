import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'user_state.dart';
import 'recent_scan.dart';
import 'result_page.dart';

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
  int _totalScans = 0;
  int _healthyScans = 0;
  int _diseasedScans = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    userState.addListener(_onStateChanged);
    scansState.addListener(_onStateChanged);
    _loadStats();
    _syncScansWithApi();
  }

  Future<void> _loadStats() async {
    final scans = scansState.scans;
    if (mounted) {
      setState(() {
        _totalScans = scans.length;
        _healthyScans = scans.where((s) => s.status == 'Healthy').length;
        _diseasedScans = scans.where((s) => s.status == 'Diseased').length;
        _statsLoaded = true;
      });
    }
  }

  Future<void> _syncScansWithApi() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://plant-pules-api.vercel.app/api/v1/scan',
        options: Options(headers: {'token': userState.token}),
      );
      final List data = response.data['data'] ?? [];
      final records = data
          .map((item) => ScanRecord.fromJson(item as Map<String, dynamic>))
          .toList();
      scansState.setAll(records);
      await saveScans();
    } catch (_) {}
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

    final totalVal = _statsLoaded ? _totalScans : scans.length;
    final healthyVal = _statsLoaded
        ? _healthyScans
        : scans.where((s) => s.status == 'Healthy').length;
    final diseasedVal = _statsLoaded
        ? _diseasedScans
        : scans.where((s) => s.status == 'Diseased').length;

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
            value: '$totalVal',
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
                  value: '$healthyVal',
                  bgColor: const Color(0xFFEBF5E9),
                  borderColor: const Color(0xFF61AF51),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  imagePath: 'assets/disease.png',
                  label: 'Diseased',
                  value: '$diseasedVal',
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
            ...latestTwo.map((scan) => _MiniScanItem(scan: scan)),
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
          child:
              userState.profileImagePath != null &&
                  userState.profileImagePath!.isNotEmpty
              ? ClipOval(
                  child: Image.file(
                    File(userState.profileImagePath!),
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    cacheWidth: 64,
                  ),
                )
              : Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color:  Color(0xFFEFF3EE),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    userState.gender.toLowerCase() == 'female'
                        ? 'assets/bigProfilePic.png'
                        : 'assets/male.png',
                    fit: BoxFit.cover,
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
