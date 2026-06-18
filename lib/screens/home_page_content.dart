import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:PlantPulse/state/user_state.dart';
import '../state/scan_record.dart';
import 'package:PlantPulse/widgets/mini_scan_item.dart';
import 'package:PlantPulse/widgets/home_widgets.dart';

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
    if (scansState.isNotEmpty) return;
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

    return RefreshIndicator(
      color: const Color(0xFF399B25),
      onRefresh: () async {
        await _syncScansWithApi();
        await _loadStats();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.0296,
            right: size.width * 0.064,
            left: size.width * 0.064,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              HomeHeader(
                firstName: widget.firstName,
                onProfileTap: widget.onProfileTap,
              ),
              SizedBox(height: size.height * 0.0296),
              const Text('Statistics',
                  style: TextStyle(color: Color(0xFF1F1F1F),
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              HomeStatCard(
                imagePath: 'assets/totalScans.png',
                label: 'Total Scans',
                value: '$totalVal',
                bgColor: const Color(0xFFEBF5E9),
                borderColor: const Color(0xFF61AF51),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: HomeStatCard(
                    imagePath: 'assets/health.png',
                    label: 'Healthy',
                    value: '$healthyVal',
                    bgColor: const Color(0xFFEBF5E9),
                    borderColor: const Color(0xFF61AF51),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: HomeStatCard(
                    imagePath: 'assets/disease.png',
                    label: 'Diseased',
                    value: '$diseasedVal',
                    bgColor: const Color(0xFFFFF4E9),
                    borderColor: const Color(0xFFFFA352),
                  )),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Scans',
                      style: TextStyle(color: Color(0xFF1F1F1F),
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: _goToRecentScan,
                    child: const Row(
                      children: [
                        Text('See More',
                            style: TextStyle(color: Color(0xFF399B25),
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: Color(0xFF399B25)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (scansState.isEmpty)
                const Text('No scans yet',
                    style: TextStyle(fontSize: 13,
                        color: Color(0xFF717171), fontFamily: 'Poppins'))
              else
                ...latestTwo.map((scan) => MiniScanItem(scan: scan)),
              const SizedBox(height: 16),
              const HomeDidYouKnow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}