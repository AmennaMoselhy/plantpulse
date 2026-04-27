import 'dart:io';
import 'package:dio/dio.dart';
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

  // 📊 Stats API
  Future<void> _loadStats() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://plant-pules-api.vercel.app/api/v1/scan/stats',
        options: Options(headers: {'token': userState.token}),
      );

      final data = response.data['data'];

      if (!mounted) return;

      setState(() {
        _totalScans = (data?['totalScans'] ?? 0);
        _healthyScans = (data?['healthyScans'] ?? 0);
        _diseasedScans = (data?['diseasedScans'] ?? 0);
        _statsLoaded = true;
      });
    } catch (e) {
      setState(() => _statsLoaded = true);
    }
  }

  // 🌿 Scans API
  Future<void> _syncScansWithApi() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://plant-pules-api.vercel.app/api/v1/scan',
        options: Options(headers: {'token': userState.token}),
      );

      final List data = response.data['data'];

      scansState.scans.clear();

      for (var item in data) {
        scansState.scans.add(ScanRecord.fromJson(item));
      }

      scansState.notifyListeners();
    } catch (e) {
      print('Error: $e');
    }
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

          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${widget.firstName}!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    "Check Your Plants' Health Summary",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: const CircleAvatar(radius: 16),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _statCard('Total Scans', _statsLoaded ? _totalScans.toString() : '${scans.length}'),
          _statCard('Healthy', _statsLoaded ? _healthyScans.toString() : '${scans.where((s) => s.status == 'Healthy').length}'),
          _statCard('Diseased', _statsLoaded ? _diseasedScans.toString() : '${scans.where((s) => s.status == 'Diseased').length}'),

          const SizedBox(height: 20),

          // Recent scans
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: _goToRecentScan,
                child: const Text('See More'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (scans.isEmpty)
            const Text("No scans yet")
          else
            ...latestTwo.map((scan) => ListTile(
              leading: Image.file(File(scan.imagePath), width: 40),
              title: Text(scan.plantName),
              subtitle: Text(scan.status),
              onTap: () {
                Navigator.push(
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
                );
              },
            )),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
